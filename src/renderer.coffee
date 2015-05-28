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

modify = (id, html) ->
  items[id]?.element.innerHTML = html

add = (id, html) ->
  return modify id, html if items[id]
  div = document.createElement('div')
  div.className = "ditem"
  div.style.backfaceVisibility = "hidden"
  div.innerHTML = html


  item = new THREE.CSS3DObject div

  matrix = new THREE.Matrix4()
    .multiply new THREE.Matrix4().makeRotationY Math.random()*Math.PI*4
    .multiply new THREE.Matrix4().makeRotationX (Math.random()-0.5)*Math.PI/3
    .multiply new THREE.Matrix4().makeTranslation 0, 0, 5

  item.applyMatrix(matrix)

  scale = 48/(Math.min(window.innerWidth,window.innerHeight)*5) * 0.5
  item.scale.set scale, scale, scale

  div.onmousedown = (ev) ->
    return unless div.classList.contains('selected') or ev.target.classList.contains('clicky')
    ev.stopPropagation()

  div.addEventListener 'click', (ev) ->
    return unless ev.target.classList.contains 'clicky'
    selection = document.getSelection()
    if item.parent is sphere
      sphere.remove item
      scene.add item
      div.classList.add 'selected'

      item.applyMatrix new THREE.Matrix4().makeRotationY sphere.rotation.y
      item.applyMatrix new THREE.Matrix4().makeTranslation 0, 0, 0.1
    else
      scene.remove item
      sphere.add item
      div.classList.remove 'selected'

      item.applyMatrix new THREE.Matrix4().makeTranslation 0, 0, -0.1
      item.applyMatrix new THREE.Matrix4().makeRotationY -sphere.rotation.y

  sphere.add item
  items[id] = item

ROTATION_SPEED = 0.001

cssrenderer.domElement.onmousedown = (ev) ->
  return unless ev.button is 0
  ev.preventDefault()
  ROTATION_SPEED = 0.01
cssrenderer.domElement.onmouseup = ->
  ROTATION_SPEED = 0.001

remove = (id) ->
  sphere.remove items[id]
  scene.remove items[id]
  delete items[id]

render = ->
  requestAnimationFrame render
  sphere.rotation.y -= ROTATION_SPEED
  renderer.render scene, camera
  cssrenderer.render scene, camera

render()

module.exports = {add, remove}


