<template>
<div>
  <v-row style="margin-bottom: 50px;" justify='start'>
    <v-col style="margin-top: 20px; margin-left: 20px">
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
      <h3 style="text-align: right;">{{time_last_update}}</h3>
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
  <h2>{{no_tickets}}</h2>
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
      bus_category: 0,
      price: 0
    },
    bus_travels: [],
    price_history: [],
    loadTable: true,
    last_update: "",
    no_tickets: "",
    time_last_update: "Fecha Última Consulta: ",
    bus_categories: [
      {id: 0, name: 'Cualquiera'},
      {id: 1, name: 'Premium'},
      {id: 2, name: 'Salón Cama'},
      {id: 3, name: 'Semi Cama'},
      {id: 4, name: 'Pullman'},
    ],

    chartData: [
        ['Hora', 'Precio', 'Precio Objetivo']
      ],
    chartOptions: {
        title: 'Historia de Precios',
        subtitle: 'Fecha última consulta: ',
        height: 300,
        interpolateNulls: true,
        series: {
          1: {
          enableInteractivity: false
          }
        }
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
          if (response.data.minutes !== null){
            if(response.data.minutes == 0){
              this.time_last_update = "Fecha Última Consulta: hace menos de un minuto."
            }
            else if (response.data.minutes == 1){
              this.time_last_update = "Fecha Última Consulta: hace 1 minuto."
            }
            else {
              this.time_last_update = "Fecha Última Consulta: hace " + response.data.minutes + " minutos."
            }

          }

        })
        .catch(e => {
         console.log(e);
        });
    },

    async getData() {
      await this.get_bus_travels();
      await this.get_price_history();
      await this.initialize();
    },

    async get_bus_travels() {
      return axios
        .get("http://localhost:3000/api/alerts/"+this.$route.params.alert_id+"/bus_travels")
        .then(response => {
          if (response.data.error) {
            this.loadTable = false;
            this.no_tickets = "No se pudieron encontrar tickets :("
            return;
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
          this.price_history.forEach(element => this.chartData.push([new Date(...element.time), element.price, null]));
          // adding price level line
          if (this.price_history === undefined || this.price_history == 0) {
            return;
          }
          if (this.price_history.length == 1){
            //price line in first load
            let hour_array = this.price_history[0].time;
            let minutes = hour_array[4];
            hour_array.splice(4, 1, minutes-1);
            this.chartData.push([new Date(...hour_array), null , this.alert.price])
            hour_array.splice(4, 1, minutes+1);
            this.chartData.splice(1, 0, [new Date(...hour_array), null , this.alert.price]);
            return
          }
          this.chartData.push([this.chartData.slice(-1)[0][0] , null , this.alert.price]);
          this.chartData.splice(1, 0, [this.chartData[1][0], null , this.alert.price]);

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