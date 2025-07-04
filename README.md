# imgtagdir
Smart folders for tagged images

## Tagging

Tag your images with a compatible app like Aves Libre Android gallery app which inserts XMP:Subject tags to the jpeg files.

## Refresh Smart Folders

Start this tool manually on demand, in the background, periodically from a cronjob or using incron and this will create symlinks of your tagged images in the specified directory so you can browse and find anything without wasting disk space.

## Troubleshooting

Check your tags in the images with:

```shell
$ exiftool -XMP:Subject IMG_xxxxxx.jpg
Subject                         : Your-tag1, tag2
```
