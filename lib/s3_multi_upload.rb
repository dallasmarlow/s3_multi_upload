require 'pathname'
require 'aws-sdk'
require 'progressbar'
require 'base64'

module S3_Multi_Upload
  class Upload
    attr_accessor :options, :file, :queue, :mutex, :s3, :bucket, :object, :progress

    def initialize options
      AWS.config :access_key_id     => options[:access_key_id],
                 :secret_access_key => options[:secret_access_key]

      @options = options
      @file    = Pathname.new options[:file]
      @queue   = Queue.new
      @mutex   = Mutex.new

      @s3      = AWS::S3.new
      @bucket  = case options[:create_bucket]
      when true
        @s3.buckets.create options[:bucket]
      else
        @s3.buckets[options[:bucket]]
      end

      @object  = @bucket.objects[options[:key] || @file.basename]

      enqueue
    end

    def normalize value, unit = :b
      case unit.downcase.to_sym
      when :b, :byte, :bytes
        value.to_f
      when :k, :kb, :kilobyte, :kilobytes
        value.to_f * (2 ** 10)
      when :m, :mb, :megabyte, :megabytes
        value.to_f * (2 ** 20)
      when :g, :gb, :gigabyte, :gigabytes
        value.to_f * (3 ** 30)
      end
    end

    def chunk_size
      normalize *options[:chunk_size].first
    end

    def enqueue
      (file.size.to_f / chunk_size).ceil.times do |index|
        queue << [chunk_size * index, index + 1]
      end
    end

    def upload
      object.multipart_upload do |upload|
        options[:threads].times.map do
          Thread.new do
            until queue.empty?
              offset, index = queue.deq :asynchronously rescue nil

              unless offset.nil?
                upload_parameters = {
                  :data        => file.read(chunk_size, offset),
                  :part_number => index,
                }

                if options[:checksum]
                  digest         = Digest::MD5.digest(upload_parameters[:data])
                  encoded_digest = Base64.encode64(digest).strip

                  upload_parameters[:content_md5] = encoded_digest
                end

                upload.add_part upload_parameters

                if options[:progress_bar]
                  mutex.synchronize do
                    progress.inc
                  end
                end
              end
            end
          end
        end.each(&:join)
      end
    end

    def progress
      @progress ||= ProgressBar.new "upload", queue.size
    end

    def process
      value, unit = *options[:chunk_size].first
      puts "uploading #{file} to s3://#{options[:bucket]}/#{object.key} using #{options[:threads]} threads in chunks of #{value} #{unit}"
      progress if options[:progress_bar]
      abort 'upload failed' unless upload
      progress.finish if options[:progress_bar]
    end

  end
end
