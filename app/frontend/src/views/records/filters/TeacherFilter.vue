<template>
    <div
     class="-content">
        <text-input
         :value="value"
         @change="change"/>
    </div>
</template>

<script>
    import { fromBaseFilter } from './filter_prototype';
    import TextInput from './inputs/TextInput';

    export default fromBaseFilter('teacher', {

        components: {TextInput}

    });
</script>
