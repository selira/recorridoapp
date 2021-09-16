<template>
  <div id="app">
    <v-app>
      <!-- <p>{{ message }}</p> -->
      <alerts/>
    </v-app>
  </div>
</template>


<script>
import alerts from "./packs/components/alerts.vue";

export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  },
  components: {
    alerts: alerts
  }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
