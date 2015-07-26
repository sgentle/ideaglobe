{EventEmitter} = require 'events'
THREE = require 'three'
require('./CSS3DRenderer.js')(THREE)

scene = new THREE.Scene
camera = new THREE.PerspectiveCamera(65, window.innerWidth / window.innerHeight, 0.1, 1000)
camera.position.z = 10
window.camera = camera


scene.add new THREE.AmbientLight(0x404040)
light = new THREE.DirectionalLight(0xffffff, 0.5)
light.position.set 5, 3, 5
scene.add light


geometry = new THREE.SphereGeometry(5, 64, 32)
material = new THREE.MeshPhongMaterial
  color: 0x2962FF
  specular: 0xdddddd
  shininess: 5
  shading: THREE.FlatShading

sphere = new THREE.Mesh(geometry, material)
scene.add sphere


renderer = new THREE.WebGLRenderer
renderer.setSize window.innerWidth, window.innerHeight
document.body.appendChild renderer.domElement

cssrenderer = new THREE.CSS3DRenderer
cssrenderer.setSize window.innerWidth, window.innerHeight
cssrenderer.domElement.style.position = 'absolute'
cssrenderer.domElement.style.top = 0
cssrenderer.domElement.style.left = 0
document.body.appendChild cssrenderer.domElement


items = {}
window.items = items

itemsa = []
updateItemsa = -> itemsa = (v for k, v of items)

modify = (id, html) ->
  items[id]?.obj.element.innerHTML = html
  items[id]

cos = Math.cos
sin2 = (x) -> Math.sin(x) ** 2
PI = Math.PI
TWOPI = PI*2

circleDist = (p1, p2) ->
  Math.asin(Math.sqrt(
    sin2((p2.x - p1.x)/2) +
    cos(p2.x)*cos(p1.x)*sin2((p2.y - p1.y)/2)
  ))

minDist = (p) ->
  itemsa.reduce (min, item) ->
    newmin = circleDist(item.rot, p); Math.min(newmin, min)
  , Infinity

# Puts an angle in the range 0-TWOPI
norm = (a) -> ((a % TWOPI) + TWOPI) % TWOPI #if a < 0 then -(-a % TWOPI) else a % TWOPI
window.norm = norm

add = (id, html) ->
  return modify id, html if items[id]
  div = document.createElement('div')
  div.className = "ditem"
  div.style.backfaceVisibility = "hidden"
  div.innerHTML = html

  item = new EventEmitter()
  item.obj = obj = new THREE.CSS3DObject div

  i = 0
  m = 0
  while m < Math.PI * 2 / 40
    rot =
      x: (Math.random()-0.5)*PI/3
      y: Math.random()*PI + PI/2 - norm sphere.rotation.y
    m = minDist rot
    i++
    return null if i == 1000

  matrix = new THREE.Matrix4()
    .multiply new THREE.Matrix4().makeRotationY rot.y
    .multiply new THREE.Matrix4().makeRotationX rot.x
    .multiply new THREE.Matrix4().makeTranslation 0, 0, 5

  obj.applyMatrix(matrix)

  item.rot = rot
  item.rd = - norm rot.y - PI/2 + sphere.rotation.y
  item.id = id

  scale = 48/(Math.min(window.innerWidth,window.innerHeight)*5) * 0.5
  obj.scale.set scale, scale, scale

  div.onmousedown = (ev) ->
    return unless div.classList.contains('selected') or ev.target.classList.contains('clicky')
    ev.stopPropagation()

  div.addEventListener 'click', (ev) ->
    return unless ev.target.classList.contains 'clicky'
    selection = document.getSelection()
    if obj.parent is sphere
      sphere.remove obj
      scene.add obj
      div.classList.add 'selected'

      obj.applyMatrix new THREE.Matrix4().makeRotationY sphere.rotation.y
      obj.applyMatrix new THREE.Matrix4().makeTranslation 0, 0, 0.1
    else
      scene.remove obj
      sphere.add obj
      div.classList.remove 'selected'

      obj.applyMatrix new THREE.Matrix4().makeTranslation 0, 0, -0.1
      obj.applyMatrix new THREE.Matrix4().makeRotationY -sphere.rotation.y

  sphere.add obj
  items[id] = item
  updateItemsa()
  item

ROTATION_SPEED = 0.001

cssrenderer.domElement.onmousedown = (ev) ->
  return unless ev.button is 0
  ev.preventDefault()
  ROTATION_SPEED = 0.01
cssrenderer.domElement.onmouseup = ->
  ROTATION_SPEED = 0.001

remove = (id) ->
  return unless items[id]
  sphere.remove items[id].obj
  scene.remove items[id].obj
  delete items[id]
  updateItemsa()
  null

render = ->
  requestAnimationFrame render
  sphere.rotation.y -= ROTATION_SPEED
  for item in itemsa when item and item.obj.parent is sphere
    ord = item.rd
    item.rd += ROTATION_SPEED
    #console.log "rd!", item.rd
    if item.rd >= 0 and ord < 0
      # console.log 'visible!', item.id, item.rd
      item.emit 'visible'
    else if item.rd >= PI
      # console.log 'hidden!', item.id, item.rd
      item.emit 'hidden'
      item.rd -= TWOPI
  renderer.render scene, camera
  cssrenderer.render scene, camera

render()

module.exports = {add, remove}


