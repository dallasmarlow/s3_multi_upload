require 'pathname'
require 'aws-sdk'
require 'progressbar'

module S3_Multi_Upload
  class Upload
    attr_accessor :options, :file, :s3, :bucket, :object, :progress

    def initialize options

      AWS.config :access_key_id     => options[:access_key_id],
                 :secret_access_key => options[:secret_access_key]

      @options = options
      @file    = Pathname.new options[:file]

      @s3      = AWS::S3.new
      @bucket  = @s3.buckets.create options[:bucket]
      @object  = @bucket.objects[options[:key] || @file.basename]

      enqueue
    end

    def normalize value, unit = nil
      case unit.to_sym.downcase
      when nil, :b, :byte, :bytes
        value.to_f
      when :k, :kb, :kilobyte, :kilobytes
        value.to_f * 1024
      when :m, :mb, :megabyte, :megabytes
        value.to_f * 1024 ** 2
      when :g, :gb, :gigabyte, :gigabytes
        value.to_f * 1024 ** 3
      end
    end 

    def chunk_size
      normalize *options[:chunk_size].first
    end

    def queue
      @queue ||= Queue.new
    end

    def enqueue
      (file.size.to_f / chunk_size).ceil.times do |index|
        queue << [chunk_size * index, index + 1]
      end
    end

    def upload
      object.multipart_upload do |upload|
        threads = []

        options[:threads].times do
          threads << Thread.new do
            until queue.empty?
              offset, index = queue.deq :asynchronously rescue nil
              
              unless offset.nil?
                upload.add_part :data        => file.read(chunk_size, offset),
                                :part_number => index

                progress.inc if options[:progress_bar]
              end
            end
          end
        end

        threads.each &:join
      end
    end

    def progress
      @progress ||= ProgressBar.new :upload, queue.size
    end

    def process
      value, unit = *options[:chunk_size].first
      puts "uploading #{file} to s3://#{options[:bucket]}/#{object.key} using #{options[:threads]} threads in chunks of #{value} #{unit}"
      progress if options[:progress_bar]
      abort 'upload failed' unless upload
      progress.finish
    end

  end
end