<template>
    <div
     class="color-scale">

        <div
         class="-row -texts">
            <div
             v-for="{text} in grades">
                {{text}}
            </div>
        </div>

        <div
         class="-row -colors">
            <div
             v-for="{css} in grades"
             :style="css">
            </div>
        </div>

        <div
         class="-row -ranges">
            <div
             v-for="{grade, min} in grades">
                <div
                 v-if="grade > 1"
                 class="mt-1 ml-2">
                    {{min}}
                </div>
            </div>
        </div>

    </div>
</template>

<script>
    import { grades, ranges, colors } from './indicators';

    export default {

        computed: {
            grades () {
                return grades.map(grade =>({
                    grade: Number(grade),
                    text: this.$t(`records.indicators.${grade}`),
                    min: `${ranges[grade][0]} +`,
                    css: { backgroundColor: colors[grade] }
                }));
            }
        }

    }
</script>
