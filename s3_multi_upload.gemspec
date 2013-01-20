Gem::Specification.new do |gem|
  gem.name     = 's3_multi_upload'
  gem.version  = '0.0.4'
  gem.authors  = ['dallas marlow', 'michael pilat']
  gem.email    = ['dallasmarlow@gmail.com', 'mike@mikepilat.com']
  gem.summary  = 's3 multipart uploads in parallel'
  gem.homepage = 'https://github.com/dallasmarlow/s3_multi_upload'

  gem.files    = [
    'bin/s3_multi_upload',
    'lib/s3_multi_upload.rb',
  ]

  gem.require_paths = ['lib']
  gem.executables   = ['s3_multi_upload']
  gem.default_executable = 's3_multi_upload'

  gem.add_dependency 'aws-sdk'
  gem.add_dependency 'thor'
  gem.add_dependency 'progressbar'
end
