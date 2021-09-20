<template>
  <div>
    <v-app>
      <!-- <p>{{ message }}</p> -->
      <router-view></router-view>
    </v-app>
  </div>
</template>


<script>
import { GChart } from 'vue-google-charts'
export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  },
  components: {
    GChart
  }
}
</script>

