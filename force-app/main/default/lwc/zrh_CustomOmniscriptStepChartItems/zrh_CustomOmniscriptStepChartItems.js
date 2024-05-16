import omniscriptStepChartItems from "vlocity_ins/omniscriptStepChartItems";
import template from "./zrh_CustomOmniscriptStepChartItems.html";

export default class zrh_CustomOmniscriptStepChartItems extends omniscriptStepChartItems {
    render() {
        return template;
    }

    handleStepClickCustom() {
        console.log('do nothing');
    }
}