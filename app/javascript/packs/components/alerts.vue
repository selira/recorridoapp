<template>
  <v-data-table :headers="headers" :items="alerts" class="elevation-1">
    <template v-slot:top>
      <v-toolbar flat color="white">
        <v-toolbar-title>recorridoApp</v-toolbar-title>
        <v-divider class="mx-4" inset vertical></v-divider>
        <v-spacer></v-spacer>
        <v-dialog v-model="dialog" max-width="900px">
          <template v-slot:activator="{ on }">
            <v-btn color="primary" dark class="mb-2" v-on="on">Nueva Alerta</v-btn>
          </template>
          <v-card>
            <v-card-title>
              <span class="headline">{{ formTitle }}</span>
            </v-card-title>

            <v-card-text>
              <v-container>
                <v-row>
                  <v-col cols="12" sm="6" md="4">
                    <v-text-field v-model="editedItem.name" label="Nombre Alerta"></v-text-field>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <!-- <v-text-field v-model="editedItem.origin" label="Ciudad de Origen"></v-text-field> -->
                    <v-autocomplete :items="cities" v-model="editedItem.departure_city"
                     color="white" item-text="name" label="Ciudad de Origen" return-object>
                     </v-autocomplete>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <v-autocomplete :items="cities" v-model="editedItem.destination_city"
                     color="white" item-text="name" label="Ciudad de Destino" return-object></v-autocomplete>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <v-text-field v-model="editedItem.price" label="Precio"></v-text-field>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <v-autocomplete :items="bus_categories" v-model="editedItem.bus_category"
                     color="white" item-text="name" label="Clase" return-object></v-autocomplete>
                  </v-col>
                </v-row>
              </v-container>
            </v-card-text>

            <v-card-actions>
              <v-spacer></v-spacer>
              <v-btn color="blue darken-1" text @click="close">Cancel</v-btn>
              <v-btn color="blue darken-1" text @click="save(editedItem)">Save</v-btn>
            </v-card-actions>
          </v-card>
        </v-dialog>
      </v-toolbar>
    </template>
    <template v-slot:[`item.action`]="{ item }">
      <v-icon small class="mr-2" @click="editItem(item)">edit</v-icon>
      <v-icon small @click="deleteItem(item)">Borrar</v-icon>
    </template>
    <template v-slot:no-data>
      <v-btn color="primary" @click="initialize">Reset</v-btn>
    </template>
  </v-data-table>
</template>

<script>

import axios from "axios";
export default {
  data: () => ({
    dialog: false,
    headers: [
      {
        text: "Nombre",
        align: "left",
        sortable: false,
        value: "name"
      },
      { text: "Ciudad de Origen", value: "departure_city_name" },
      { text: "Ciudad de Destino", value: "destination_city_name" },
      { text: "Clase", value: "bus_category" },
      { text: "Precio", value: "price" },
      { text: "Actions", value: "action", sortable: false }
    ],
    bus_categories: [
      {id: 0, name: 'Cualquiera'},
      {id: 1, name: 'Premium'},
      {id: 2, name: 'Salón Cama'},
      {id: 3, name: 'Semi Cama'},
      {id: 4, name: 'Pullman'},
      ],
    alerts: [],
    cities: [],
    editedIndex: -1,
    editedItem: {
      name: "Nueva Alerta",
      departure_city: {},
      destination_city: {},
      bus_category: {id: 0, name: 'Cualquiera'},
      price: 0
    },
    defaultItem: {
      name: "Nueva Alerta",
      departure_city: {},
      destination_city: {},
      bus_category: {id: 0, name: 'Cualquiera'},
      price: 0
    }
  }),
  computed: {
    formTitle() {
      return this.editedIndex === -1 ? "Nueva Alerta" : "Editar Alerta";
    }
  },
  watch: {
    dialog(val) {
      val || this.close();
    }
  },
  created() {
    this.initialize();
    this.getCities();
    
  },
  methods: {
  
    close() {
      this.dialog = false;
      setTimeout(() => {
        this.editedItem = Object.assign({}, this.defaultItem);
        this.editedIndex = -1;
      }, 300);
    },

    async initialize() {
    return axios
      .get("http://localhost:3000/alerts")
      .then(response => {
        let alerts = response.data.map(item => {
          let temp = Object.assign({}, item);
          temp.bus_category = this.bus_categories[item.bus_category].name;
          return temp;
        });
        this.alerts = alerts;
      })
      .catch(e => {
        console.log(e);
      });
    },

    async getCities() {
    return axios
      .get("http://localhost:3000/cities")
      .then(response => {
        this.cities = response.data.cities;
      })
      .catch(e => {
        console.log(e);
      });
    },

    editItem(item) {
      this.editedIndex = item.id;
      this.editedItem = Object.assign({}, item);
      this.editedItem.destination_city = {name: item.destination_city_name}
      this.editedItem.departure_city = {name: item.departure_city_name}
      // this.editedItem.bus_category = this.bus_categories[item.bus_category].name
      this.dialog = true;
    },

    save(item) {
      if (this.editedIndex > -1) {
        axios
        .put(`http://localhost:3000/alerts/${item.id}`, {
          name: this.editedItem.name,
          departure_city_name: this.editedItem.departure_city.name,
          departure_city_url_name: this.editedItem.departure_city.url_name,
          departure_city_id: this.editedItem.departure_city.id,
          destination_city_name: this.editedItem.destination_city.name,
          destination_city_url_name: this.editedItem.destination_city.url_name,
          destination_city_id: this.editedItem.destination_city.id,
          bus_category: this.editedItem.bus_category.id,
          price: this.editedItem.price,
        })
        .then(response => {
          this.initialize();
        })
        .catch(error => {
          console.log(error);
        });
      } 
      else {
        axios
          .post(`http://localhost:3000/alerts/`, {
            name: this.editedItem.name,
            departure_city_name: this.editedItem.departure_city.name,
            departure_city_url_name: this.editedItem.departure_city.url_name,
            departure_city_id: this.editedItem.departure_city.id,
            destination_city_name: this.editedItem.destination_city.name,
            destination_city_url_name: this.editedItem.destination_city.url_name,
            destination_city_id: this.editedItem.destination_city.id,
            bus_category: this.editedItem.bus_category.id,
            price: this.editedItem.price,
          })
          .then(response => {
            this.initialize();
          })
          .catch(error => {
            console.log(error);
          });
      }
      this.close();
    },
    deleteItem(item) {
      confirm("Are you sure you want to delete this item?"); 
      axios
        .delete(`http://localhost:3000/alerts/${item.id}`)
        .then(response => {
          alert(response.data.json);
          this.initialize();
        })
        .catch(error => {
          console.log(error);
        });
}
  }

};

</script>