<template>
    <v-alert
     :value="true"
     type="error">
        <div
         v-for="(item, index) in items"
         :key="index"
         class="ma-2">
            {{item}}
        </div>
    </v-alert>
</template>

<script>
export default {
    props: ['messages'],

    computed: {
        items () {
            return (this.messages || []);
        }
    }
};
</script>
