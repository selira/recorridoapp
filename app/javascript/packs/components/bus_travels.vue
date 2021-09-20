<template>
<div>
  <h1>{{alert.name}}</h1>
  <h3>Origen: {{alert.departure_city_name}}</h3>
  <h3>Destino: {{alert.destination_city_name}}</h3>
  <h3>Precio: {{alert.price}}</h3>
  <h3>Clase: {{bus_categories[alert.bus_category].name}}</h3>
  <router-link to="/">
    <v-icon small class="mr-2" @click="goBack()">fa-arrow-left</v-icon>
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
    :items="bus_travels"
    hide-default-footer
    item-key="name"
    class="elevation-1"
    :loading = "loadTable"
    loading-text="Loading... Please wait"
    :item-class="itemRowBackground"
  > 
  <template #item.date="{ item }">
    <a target="_blank" :href="item.link">
      {{ item.date }}
    </a>
  </template></v-data-table>
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
    bus_travels: [],
    price_history: [],
    loadTable: true,
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
    headers: [
        {
          text: 'Fecha',
          align: 'start',
          sortable: false,
          value: 'date',
        },
        { text: 'Horario', value: 'time', sortable: false, },
        { text: 'Clase', value: 'bus_category', sortable: false, },
        { text: 'Precio Mínimo', value: 'price', sortable: false, },
        { text: 'Empresa de Bus', value: 'company', sortable: false, },
      ],

  }),

  created() {
    this.initialize();
    this.get_bus_travels();
    this.get_price_history();
  },

  methods: {
  
    async initialize() {
      return axios
        .get("http://localhost:3000/api/alerts/"+this.$route.params.alert_id)
        .then(response => {
          // let alert = response.data;
          // alert = this.bus_categories[alert[bus_category]];
          // this.alert = alert;
          this.alert = response.data;
        })
        .catch(e => {
         console.log(e);
        });
    },

    async get_bus_travels() {
      return axios
        .get("http://localhost:3000/api/alerts/"+this.$route.params.alert_id+"/bus_travels")
        .then(response => {
          let bus_travels = response.data.map(item => {
          let temp = Object.assign({}, item);
          temp.bus_category = this.bus_categories[item.bus_category].name;
          temp.link = "https://demo.recorrido.cl/es/bus/" + this.alert.departure_city_url_name +
           "/" + this.alert.destination_city_url_name + "/" + item.date
          temp.green = item.price < this.alert.price;
          return temp;
          });
          this.bus_travels = bus_travels;
          this.loadTable = false;
        })
        .catch(e => {
         console.log(e);
        });
    },

    async get_price_history() {
      return axios
        .get("http://localhost:3000/api/alerts/"+this.$route.params.alert_id+"/price_history")
        .then(response => {
          this.price_history = response.data;
        })
        .catch(e => {
         console.log(e);
        });
    },

    goBack(){
      this.$router.push({ path: '/'});
    },

    itemRowBackground(item) {
     return item.green? 'style-1' : 'style-2'
  }

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
  .style-1 {
    background-color: rgb(178, 224, 178);
  }
  .style-2 {
    background-color: white;
  }
</style>