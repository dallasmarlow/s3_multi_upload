parallelized multipart s3 uploads

### installation
gem i s3_multi_upload

### usage

```
dallas$ s3_multi_upload help upload

Usage:
  s3_multi_upload upload --access-key-id=ACCESS_KEY_ID         \
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