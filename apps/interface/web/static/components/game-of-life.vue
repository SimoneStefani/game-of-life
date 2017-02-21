<template>
  <div class="my-app" id="pew" style="text-align: center">
    <h1 @click="toggle">Game of Life Elixir</h1>
    <h4>{{ active }} cells are alive</h4>
    <canvas id="canvas"></canvas>
  </div>
</template>

<script>

import {Socket} from 'phoenix'

export default {

  data () {
    return {
      canvas: null,
      context: null,
      scale: 10,
      interval: 100,
      simulating: true,
      active: 0
    }
  },

  computed: {

  },

  mounted () {
    this.setupCanvas()
    this.setupSocket()
  },

  methods: {
    setupCanvas () {
      this.canvas = document.getElementById("canvas")
      this.context = this.canvas.getContext("2d")
      let ratio = this.getPixelRatio(this.context)
      this.canvas.width = document.getElementById("pew").clientWidth * ratio
      this.canvas.height = (document.getElementById("pew").clientWidth - 30) * ratio
      this.canvas.style.width = `${document.getElementById("pew").clientWidth}px`
      this.canvas.style.height = `${document.getElementById("pew").clientWidth - 30}px`
      this.context.scale(ratio, ratio)
      this.context.fillStyle = 'rgb(111, 168, 220)'
    },

    getPixelRatio (context) {
      var backingStore = context.backingStorePixelRatio ||
              context.webkitBackingStorePixelRatio ||
              context.mozBackingStorePixelRatio ||
              context.msBackingStorePixelRatio ||
              context.oBackingStorePixelRatio ||
              context.backingStorePixelRatio || 1

      return (window.devicePixelRatio || 1) / backingStore
    },

    render (positions) {
      this.context.clearRect(0, 0, this.canvas.width, this.canvas.height)
      positions.forEach(({x, y}) => {
          this.context.fillRect(x * this.scale, y * this.scale, this.scale, this.scale)
      })
      this.active = positions.length
    },

    setupSocket () {
    let socket = new Socket("/socket")
    let playing = false

    socket.connect()

    let channel = socket.channel("life", {});
    channel.join()
        .receive("ok", cells => {
            this.render(cells.positions);
            this.simulate(channel)
          })
        .receive("error", resp => console.error);
    },

    simulate (channel) {
      channel.on("tick", cells => {
        this.render(cells.positions)
      })

      if (this.simulating) {
          setTimeout(function tick() {
            channel.push("tick")
            setTimeout(tick, 100)
          }, 100)
      }
    },

    toggle () {
      this.simulating = !this.simulating
    }
  }
}
</script>

<style lang="sass">
#canvas {
  background-color: rgb(245, 245, 245);
  border-radius: 5pt;
}
</style>