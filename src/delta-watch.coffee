{spawn, exec} = require 'child_process'
fs = require 'fs'

class ModWatch
  # Handler for error and stdout
  handleError = (err, stdout, stderr) ->
    if err
      console.log err.stack
    if stdout
      console.log stdout
      
  # main watch method
  # input args:
  #   target: folder to watch
  #   recursive: flag to watch subdirectories
  #   handler: handler script for change events. either a shell script or a callback function
  watch: (target, recursive, handler) ->
    path = fs.realpathSync(target)
    console.log "delta-watch: Watching " + path

    # cache files watched
    watched = []

    # script wrapper for change
    changeHandler = () ->
      console.log "delta-watch: found change"
      if typeof handler is "function" then handler() else exec handler, handleError

    # helper recurisively collect files and dirs in a dir
    traverseFileSystem = (files, currentPath, recursive) ->
      current = fs.realpathSync currentPath
      stats = fs.statSync(current)
      # cache
      files.push current
      # recurse if directory and recursive flag on
      if recursive is on and stats.isDirectory() and files.join('=').indexOf("#{current}=") < 0
        #recursive call through sub directories
        currFiles = fs.readdirSync current
        for file in currFiles
          do (file) ->
            currentFile = currentPath + '/' + file
            traverseFileSystem files, currentFile, recursive
            
    # private watch method to do the real work
    _watch = () ->
      watchedfiles = []
      
      # get files to watch
      traverseFileSystem watchedfiles, target, recursive

      # loop over files to watch
      for folder in watchedfiles then do (folder) ->
        # only watch new files
        if( watched.indexOf(folder) is -1)
          # track new file
          watched.push folder
          # get watch approach
          if fs.statSync(folder).isDirectory()
            watcher = fs.watch
          else
            watcher = fs.watchFile
          
          # and finally watch the file/folder
          watcher folder, { persistent: true }, (curr, prev) ->
            # invoke handler
            changeHandler()
            # reprime watching to take into account newly added files
            _watch()
    
    _watch()

module.exports = new ModWatch