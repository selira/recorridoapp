<template>
  <div>
    <v-app>
      <!-- <p>{{ message }}</p> -->
      <router-view></router-view>
    </v-app>
  </div>
</template>


<script>
import alerts from "./packs/components/alerts.vue";
import bus_travels from "./packs/components/bus_travels.vue";

export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  },
  // components: {
  //   alerts: alerts,
  //   bus_travels: bus_travels
  // }
}
</script>

<style scoped>
p {
  font-size: 2em;
  text-align: center;
}
</style>
