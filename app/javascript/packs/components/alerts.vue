<template>
  <v-data-table :headers="headers" :items="alerts" class="elevation-1">
    <template v-slot:top>
      <v-toolbar flat color="white">
        <v-toolbar-title>Recorrido CRUD</v-toolbar-title>
        <v-divider class="mx-4" inset vertical></v-divider>
        <v-spacer></v-spacer>
        <v-dialog v-model="dialog" max-width="500px">
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
                    <v-text-field v-model="editedItem.origin" label="Ciudad de Origen"></v-text-field>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <v-text-field v-model="editedItem.destination" label="Ciudad de Destino"></v-text-field>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <v-text-field v-model="editedItem.price" label="Precio"></v-text-field>
                  </v-col>
                  <v-col cols="12" sm="6" md="4">
                    <v-text-field v-model="editedItem.bus_category" label="Clase"></v-text-field>
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
      { text: "Ciudad de Origen", value: "origin" },
      { text: "Ciudad de Destino", value: "destination" },
      { text: "Clase", value: "bus_category" },
      { text: "Precio", value: "price" },
      { text: "Actions", value: "action", sortable: false }
    ],
    alerts: [],
    editedIndex: -1,
    editedItem: {
      name: "",
      origin: "",
      destination: "",
      bus_category: "",
      price: ""
    },
    defaultItem: {
      name: "",
      origin: "",
      destination: "",
      bus_category: "",
      price: ""
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
  },
  methods: {
  
    close() {
      this.dialog = false;
      setTimeout(() => {
        this.editedItem = Object.assign({}, this.defaultItem);
        this.editedIndex = -1;
      }, 300);
    },

    initialize() {
    return axios
      .get("http://localhost:3000/alerts")
      .then(response => {
        console.log(response.data);
        this.alerts = response.data;
      })
      .catch(e => {
        console.log(e);
      });
    }
  }

};

</script>