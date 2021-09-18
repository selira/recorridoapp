<template>
  <div>
    <v-app>
      <!-- <p>{{ message }}</p> -->
      <router-view></router-view>
    </v-app>
  </div>
</template>


<script>
export default {
  data: function () {
    return {
      message: "Hello Vue!"
    }
  },
}
</script>

