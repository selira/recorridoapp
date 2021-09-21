<template>
<div>
  <v-row style="margin-bottom: 50px;" justify='start'>
    <v-col>
      <h1>{{alert.name}}</h1>
      <h3>Origen: {{alert.departure_city_name}}</h3>
      <h3>Destino: {{alert.destination_city_name}}</h3>
      <h3>Precio: {{alert.price}}</h3>
      <h3>Clase: {{bus_categories[alert.bus_category].name}}</h3>
      <router-link to="/">
        <v-icon small class="mr-2" @click="goBack()">fa-arrow-left</v-icon>
      </router-link>
    </v-col>
    <v-col>
      <GChart
        type="LineChart"
        :data="chartData"
        :options="chartOptions"
      />
    </v-col>
  </v-row>
  <v-data-table
    dense
    :headers="headers"
    :items="bus_travels"
    hide-default-footer
    item-key="name"
    class="elevation-1"
    :loading = "loadTable"
    loading-text="Buscando tickets con los mejores precios!..."
    :item-class="itemRowBackground"
  > 
  <template v-slot:[`item.date`]="{ item }">
    <a target="_blank" :href="item.link">
      {{ item.date }}
    </a>
  </template></v-data-table>
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
    last_update: "",
    bus_categories: [
      {id: 0, name: 'Cualquiera'},
      {id: 1, name: 'Premium'},
      {id: 2, name: 'Salón Cama'},
      {id: 3, name: 'Semi Cama'},
      {id: 4, name: 'Pullman'},
    ],

    chartData: [
        ['Hora', 'Precio']
      ],
    chartOptions: {
        title: 'Historia de Precios',
        subtitle: 'Fecha última consulta: ',
        height: 300,
        // width: 1300
    },
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
    this.getData();
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

    async getData() {
      await this.get_bus_travels();
      await this.get_price_history();
    },

    async get_bus_travels() {
      return axios
        .get("http://localhost:3000/api/alerts/"+this.$route.params.alert_id+"/bus_travels")
        .then(response => {
          if (response.data === undefined || response.data == 0) {
            this.loadTable = false;
          }
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
          this.price_history.forEach(element => this.chartData.push([new Date(...element.time), element.price]));
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