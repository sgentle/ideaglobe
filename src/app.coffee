require './style.css'

pouch = require 'pouchdb'

renderer = require './renderer.coffee'

DB_URL = "#{document.location.href}/api"
DB_URL = "http://localhost:5984/ideas/"
remotedb = pouch(DB_URL)
db = pouch('ideas')

visible = {}
available = {}

addDoc = (doc) ->
  id = doc._id
  if visible[id] then visible[id] = doc else available[id] = doc

removeDoc = (id) ->
  delete visible[id]
  delete available[id]

makeVisible = (id) ->
  visible[id] = available[id] if available[id]
  delete available[id]

makeAvailable = (id) ->
  available[id] = visible[id] if visible[id]
  delete visible[id]

getAvailable = ->
  i = 0
  doc = null
  for _, current of available
    if Math.floor(Math.random()*i) is 0
      picked = i
      doc = current
    i++
  #console.log "found", doc._id, "number", picked
  doc

db.replicate.from remotedb, live: true, retry: true

# Material Design icon by Google: https://github.com/google/material-design-icons/
LINK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 48 48"><path d="M38 38H10V10h14V6H10c-2.21 0-4 1.79-4 4v28c0 2.21 1.79 4 4 4h28c2.21 0 4-1.79 4-4V24h-4v14zM28 6v4h7.17L15.51 29.66l2.83 2.83L38 12.83V20h4V6H28z"/></svg>"""

render = (doc) ->
  return unless doc.name
  html = "<div class='dbox #{doc.type or 'idea'}'>"
  html += "<div class='name clicky'>#{doc.name}</div>"

  if doc.notes or doc._attachments
    html += "<div class='notes'>"
    if doc.notes
      html += "<span>#{doc.notes}</span>"
    if doc._attachments
      url = url for url of doc._attachments
      html += "<img src='#{DB_URL+'/'+doc._id+'/'+url}'>"
    if doc.link
      html += "<a href='#{doc.link}' target='_blank'>#{LINK_SVG}</a>"
    html += "</div>"

  html += "</div>"
  item = renderer.add doc._id, html
  if item
    item.once 'hidden', ->
      makeAvailable doc._id
      unrender doc._id
      maybeRender()
  item

unrender = (id) -> renderer.remove id

maybeRender = ->
  return unless doc = getAvailable()
  vis = Object.keys(visible)
  if vis.length < 20
    makeVisible doc._id
    render doc

db.allDocs(include_docs: true).then (result) ->
  for row, i in result.rows
    addDoc row.doc
    maybeRender() if i < 5

db.changes(since: 'now', live: true).on 'change', (change) ->
  if change.deleted
    removeDoc change.id
    unrender change.id
  else
    db.get(change.id).then (doc) ->
      addDoc doc
      maybeRender()

setInterval maybeRender, 500