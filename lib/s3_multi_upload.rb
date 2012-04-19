require 'pathname'
require 'aws-sdk'

module S3_Multi_Upload
  class Upload

    attr_accessor :config, :bucket, :file

    def initialize config, bucket, file
      @file   = Pathname.new file

      @config = {
        :key => @file.basename,
        :threads    => 5,
        :chunk_size => 10 * 1024 * 1024, # MB
      }.merge config

      AWS.config :access_key_id     => config[:access_key_id],
                 :secret_access_key => config[:secret_access_key]

      @bucket = s3.buckets.create bucket
      enqueue
    end

    def s3
      @s3 ||= AWS::S3.new
    end

    def object
      @object ||= bucket.objects[config[:key]]
    end

    def queue
      @queue ||= Queue.new
    end

    def enqueue
      (file.size.to_f / config[:chunk_size]).ceil.times do |index|
        queue << [config[:chunk_size] * index, index + 1]
      end
    end

    def upload
      object.multipart_upload do |upload|
        threads = []

        config[:threads].times do
          threads << Thread.new do
            until queue.empty?
              offset, index = queue.deq :asynchronously rescue nil

              unless offset.nil?
                upload.add_part :data => file.read(config[:chunk_size], offset),
                                :part_number => index
              end
            end
          end
        end

        threads.each &:join
      end
    end

    def process
      if upload
        puts "#{file} uploaded to #{config[:bucket]} as #{config[:key]}"
        exit
      else
        abort "upload failed"
      end
    end

  end
end