fs = require 'fs'
path = require 'path'
wrench = require 'wrench'
should = require 'should'
modwatch = require '../index'

TEST_DIR = 'tmp'

before((done)->
  if not path.existsSync TEST_DIR
    fs.mkdirSync TEST_DIR
  done()
)

after((done)->
  wrench.rmdirSyncRecursive TEST_DIR, false
  done()
)

describe 'mod-watch', ->
  it('should detect a new file', (done)->
    add = "#{TEST_DIR}/add"
    fs.mkdirSync add
    modwatch.watch add, true, () ->
      done()
    setTimeout( ()->
      fs.writeFileSync  "#{add}/test.txt"
    , 500)
  )
  
  it('should detect when a file is removed', (done)->
    del = "#{TEST_DIR}/del"
    fs.mkdirSync del
    file = "#{del}/test2.txt"
    fs.writeFileSync  file
    modwatch.watch del, true, () ->
      done()

    setTimeout( ()->
      fs.unlinkSync file
    , 500)
  )

  it('should detect when a file is updated', (done)->
     add = "#{TEST_DIR}/update"
     fs.mkdirSync add
     file = "#{add}/test3.txt"
     fs.writeFileSync  file
     modwatch.watch add, true, () ->
       done()
     setTimeout( ()->
       fs.writeFileSync file, "Hey there!"
     , 500)
   )

   it('should detect changes to nested directories', (done)->
      add = "#{TEST_DIR}/recursive"
      fs.mkdirSync add
      rec = "#{add}/nested"
      fs.mkdirSync rec
      file = "#{rec}/test4.txt"
      fs.writeFileSync  file
      modwatch.watch add, true, () ->
        done()
      setTimeout( ()->
        fs.unlinkSync file
      , 500)
    )
