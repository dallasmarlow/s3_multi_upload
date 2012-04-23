## parallelized multipart s3 uploads
```bash
root@ip-10-108-242-120:~# s3_multi_upload --access-key-id xxx      \
                                          --secret-access-key xxx  \ 
        								  --bucket s3_multi_upload \ 
										  --chunk-size 25:mb       \
										  --threads 40             \
										  --key uploads/u.iso      \
										  --file ubuntu-12.04-beta2-dvd-amd64.iso

uploading ubuntu-12.04-beta2-dvd-amd64.iso to s3://s3_multi_upload/uploads/u.iso using 40 threads in chunks of 25mb
upload:         20% |oooooooooooooooooooooo                                                        | ETA:   0:01:36
```


### installation
```
gem install s3_multi_upload
```

### usage

```
Usage:
  s3_multi_upload  --access-key-id=ACCESS_KEY_ID         \
                   --secret-access-key=SECRET_ACCESS_KEY \
                   --bucket=BUCKET                       \ 
                   --file=FILE                           


Options:
  --access-key-id=ACCESS_KEY_ID          
  --secret-access-key=SECRET_ACCESS_KEY  
  --bucket=BUCKET                        
  --file=FILE                            

  --threads=N                            
                                         # Default: 5

  --chunk-size=amount:unit                 
                                         # Default: {10=>:mb}

  [--progress-bar]                       
                                         # Default: true

  [--key=KEY]                            # s3 object key (default: file name)
```

### example

```
s3_multi_upload --access-key-id xxx     \
                --secret-access-key xxx \
                --bucket xxx            \
                --file /path/to/file    \
                --no-progress-bar       \ # disable the progress bar
                --chunk-size 50:mb      \ # increase the chunk size
                --threads 40              # increase the number of threads
```