# plex_the_ripper
Plex The MKVMaker Ripper

Currently this only work on Mac... Also you need to [download MKV](https://www.makemkv.com/download/makemkv_v1.14.3_osx.dmg)
The goal it to hopefully make it work on windows as well. But I have to keep working on that.


## Setup
```shell
git clone https://github.com/newdark/plex_the_ripper.git
```

# Usage

If you want to just rip a movie.

```shell
bin/rip
```
The tool will prompt with questions that you answer as you use it. It will also install some gems it needs
to parse the information off makemkv. Another option that is added and I recommend is to use the https://www.themoviedb.org/ api.
This helps a lot for movies and TV shows as it will use there database to format the file names with extra metadata.

Plus it helps MKVmaker make better decisition about what titles to rip off the disc.
```shell
bin/rip --api-key a15f04ccfb72f83614f8ad670asdf7574
```

There is also a option to setup slack with this tool. I found that can be nice because you may want to walk away from the ripping process. This way it will send you a slack message and then you can come back and put another disc in.

```shell
bin/rip --slack-url https://hooks.slack.com/services/T7VNSDFSS/SSD1K6PDQD/SDF9Qrgl0VRkxlWeukdYUJzt
```

Example of what the output on slack looks like for a Movie
```
Finished ripping Star Trek Season 01 Disc 07
It took a total of 00 hours, 27 minutes, 58 seconds to rip Star Trek
```

If you have questions about the options uses the help. That has most of the update documentation.
```shell
bin/rip --help
```
```shell
Usage: rip [options]

Specific options:
    -i, --include-extras             All other titles that are not the main movie will be added to the "Behind The Scenes" folder so plex can watch them. This will set the --min-length "\
         "to zero unless --min-length option is used
    -a, --api-key [Key]              API key provide by themoviedb.org
    -u, --slack-url [URL]            Slack Web Hook. Can be handy if you want to notify a channel of the progress or details of how the rip is going
    -r, --media-folder [Folder]      Where would you like use to rip the files to. ("/Volumes/Multimedia")
        --make-backup [BackupFolder] Make a disk backup rather than ripping the movie
    -l, --min-length [SECONDS]       The minimum amount of time that a video length should be. Exlude anything less than (1) seconds
    -x, --max-length [SECONDS]       The max amount of time that a video length should be. Anything less than will not be copied (nil)
    -s, --tv-season [NUMBER]         Provide the season number if TV show
    -t, --type [TYPE]                Set the type disc type (tv, movie)
    -e, --episode-number [NUMBER]    TV episode number
    -d, --disc-number [NUMBER]       TV session disc number
    -m, --movie-name [NAME]          Name of the movie or TV show
    -f, --file-source [FolderName]   If you want open files in folder <FolderName>
    -v, --[no-]verbose               Run verbosely
    -h, --help                       Prints this help
```

All the other options in the help that I have not given examples for are optional. The one that I know does not really work right now is the `--include-extras` It kinda of is hit and miss if it will work. I need to improve on that. I would say if you want the extras off the disc you would be better off just using makeMKV and doing it by hand for now.

All options are prompted so you should not have to provde extra flags unless you fell it really is needed.

Something else to note. There is a movie duplicate checker in the tool. I added this beause I found if you ripping a large volumne of movies some times you might be creating the same one twice. This also might mean you have a better quality movie. If it prompts you about a duplicate I would be careful. It will delete the original before it start to copy the new file. I have to improve on that so it is a bit safer about how it does this.
