require './style.css'

pouch = require 'pouchdb'

renderer = require './renderer.coffee'

DB_URL = "#{document.location.href}/api"

remotedb = pouch(DB_URL)
db = pouch('ideas')

db.replicate.from remotedb, live: true, retry: true

# Material Design icon by Google: https://github.com/google/material-design-icons/
LINK_SVG = """<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 48 48"><path d="M38 38H10V10h14V6H10c-2.21 0-4 1.79-4 4v28c0 2.21 1.79 4 4 4h28c2.21 0 4-1.79 4-4V24h-4v14zM28 6v4h7.17L15.51 29.66l2.83 2.83L38 12.83V20h4V6H28z"/></svg>"""
render = (doc) ->
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
  renderer.add doc._id, html

unrender = (id) -> renderer.remove id

db.allDocs(include_docs: true).then (result) ->
  render row.doc for row in result.rows

db.changes(since: 'now', live: true).on 'change', (change) ->
  if change.deleted
    unrender change.id
  else
    db.get(change.id).then render
