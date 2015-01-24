
Gulp-reloader
----

Gulp Plugin of [devtools-reloader-station][station] to reload tabs on file changes.

You may need [Chrome Extension][crx] to finish the job in the browser part.

[station]: https://github.com/mvc-works/devtools-reloader-station
[crx]: https://github.com/mvc-works/devtools-reloader-crx

### Usage

```
npm --save-dev gulp-reloader
```

```coffee
reloader = require 'gulp-reloader'

gulp.task 'watch', ->
  reloader.listen()
  gulp
  .src 'coffee/*'
  .pipe compile() # implement by yourself
  .pipe reloader('patterns in url')
```

Since `0.0.2` there's a `300ms` debounce in case of frequent file changes.

### License

MIT