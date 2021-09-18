<template>
<div>
  <h2>{{alert.name}}</h2>
  <h4>Origen: {{alert.departure_city_name}}</h4>
  <h4>Destino: {{alert.destination_city_name}}</h4>
  <h4>Precio: {{alert.price}}</h4>
  <h4>Clase: {{alert.bus_category}}</h4>
  <router-link to="/">
    <v-icon>back</v-icon>
  </router-link>
  <v-card
    class="mt-4 mx-auto"
    max-width="400"
  >
    <v-sheet
      class="v-sheet--offset mx-auto"
      color="cyan"
      elevation="12"
      max-width="calc(100% - 32px)"
    >
      <v-sparkline
        :labels="labels"
        :value="value"
        color="white"
        line-width="2"
        padding="16"
      ></v-sparkline>
    </v-sheet>

    <v-card-text class="pt-0">
      <div class="text-h6 font-weight-light mb-2">
        User Registrations
      </div>
      <div class="subheading font-weight-light grey--text">
        Last Campaign Performance
      </div>
      <v-divider class="my-2"></v-divider>
      <v-icon
        class="mr-2"
        small
      >
        mdi-clock
      </v-icon>
      <span class="text-caption grey--text font-weight-light">last registration 26 minutes ago</span>
    </v-card-text>
  </v-card>
  <template>
  <v-data-table
    dense
    :headers="headers"
    :items="desserts"
    hide-default-footer
    item-key="name"
    class="elevation-1"
    loading
    loading-text="Loading... Please wait"
  ></v-data-table>
</template>
</div>
</template>

<script>
import axios from 'axios';
export default {
  data: () => ({
    alert: {
      name: "",
      departure_city: {},
      destination_city: {},
      bus_category: {id: 0, name: 'Cualquiera'},
      price: 0
    },
    bus_categories: [
      {id: 0, name: 'Cualquiera'},
      {id: 1, name: 'Premium'},
      {id: 2, name: 'Salón Cama'},
      {id: 3, name: 'Semi Cama'},
      {id: 4, name: 'Pullman'},
    ],

    labels: [
      '12am',
      '3am',
      '6am',
    ],

    value: [
      200,
      675,
      410,
      390,
      310,
      460,
      250,
      240,
    ],
    desserts: [
        {
          name: 'Frozen Yogurt',
          calories: 159,
          fat: 6.0,
          carbs: 24,
          protein: 4.0,
          iron: '1%',
        },
        {
          name: 'Ice cream sandwich',
          calories: 237,
          fat: 9.0,
          carbs: 37,
          protein: 4.3,
          iron: '1%',
        },
        {
          name: 'Eclair',
          calories: 262,
          fat: 16.0,
          carbs: 23,
          protein: 6.0,
          iron: '7%',
        }],
    headers: [
        {
          text: 'Dessert (100g serving)',
          align: 'start',
          sortable: false,
          value: 'name',
        },
        { text: 'Calories', value: 'calories' },
        { text: 'Fat (g)', value: 'fat' },
        { text: 'Carbs (g)', value: 'carbs' },
        { text: 'Protein (g)', value: 'protein' },
        { text: 'Iron (%)', value: 'iron' },
      ],

  }),

  created() {
    this.initialize();
  },

  methods: {
  
    async initialize() {
      return axios
        .get("http://localhost:3000/api/alerts/"+this.$route.params.alert_id)
        .then(response => {
          // let alert = response.data;
          // alert = this.bus_categories[alert[bus_category]];
          // this.alert = alert;
          console.log(response.data)
          this.alert = response.data;
        })
        .catch(e => {
         console.log(e);
        });
    },
  },
}
</script>

<style>
  .v-sheet--offset {
    top: -24px;
    position: relative;
  }
  /* .v-data-table {
    top: 400px;
  } */
</style>