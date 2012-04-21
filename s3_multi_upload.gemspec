Gem::Specification.new do |s|
  s.name    = 's3_multi_upload'
  s.version = '0.0.1'
  s.authors = ['dallas marlow']
  s.email   = ['dallasmarlow@gmail.com']
  s.summary = 's3 multipart uploads in parallel'
 
  s.files   = [
    'bin/s3_multi_upload',
    'lib/s3_multi_upload.rb',
  ]

  s.require_paths = ['lib']
  s.executables   = ['s3_multi_upload']
  s.default_executable = 's3_multi_upload'

  %w[aws-sdk thor progress_bar].each do |gem|
    s.add_dependency gem
  end
end

