let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"bottom","size":"xx-small","label":"bottom:xx-small"}],"margin":[{"type":"bottom","size":"x-small","label":"bottom:x-small"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12 ","class":"slds-card slds-p-bottom_xx-small slds-m-bottom_x-small ","background":{"color":"","image":"","size":"","repeat":"","position":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"      \n         "},"components":{"layer-0":{"children":[{"name":"Block","element":"block","size":{"isResponsive":false,"default":12},"stateIndex":0,"class":"slds-col ","property":{"label":"","collapsible":false,"record":"{record}","collapsedByDefault":false,"card":"{card}","action":{"label":"Action","iconName":"standard-default","eventType":"onclick","actionList":[{"key":"1688260024115-icfzcfj2b","label":"Action","draggable":false,"isOpen":true,"card":"{card}","stateAction":{"id":"flex-action-1688260052803","type":"Custom","displayName":"Action","vlocityIcon":"standard-default","targetType":"Record","openUrlIn":"New Tab/Window","Record":{"targetName":"Quote","targetAction":"view","targetId":"{Id}"}},"actionIndex":0}],"showSpinner":"false"},"data-conditions":{"id":"state-condition-object","isParent":true,"group":[{"id":"state-new-condition-0","field":"Id","operator":"!=","value":"","type":"custom","hasMergeField":false}]}},"type":"block","styleObject":{"size":{"isResponsive":false,"default":12},"padding":[{"type":"around","size":"small","label":"around:small"}],"class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_small ","sizeClass":"slds-size_12-of-12 ","margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#cccccc","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         "},"children":[{"name":"Icon","element":"flexIcon","size":{"isResponsive":false,"default":"1"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","card":"{card}","iconType":"Salesforce SVG","iconName":"standard:quotes","size":"medium","extraclass":"slds-icon_container slds-icon-standard-quotes ","variant":"inverse","imgsrc":""},"type":"element","styleObject":{"size":{"isResponsive":false,"default":"1"},"sizeClass":"slds-size_1-of-12 ","padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","class":"","style":"      \n         "},"elementLabel":"Block-1-Icon-0","key":"element_element_block_0_0_flexIcon_0_0","parentElementKey":"element_block_0_0","styleObjects":[{"key":0,"conditions":"default","styleObject":{"size":{"isResponsive":false,"default":"1"},"sizeClass":"slds-size_1-of-12 ","padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","class":"","style":"      \n         "},"label":"Default","name":"Default","conditionString":"","draggable":false}]},{"name":"NumeroCotizacion","element":"outputField","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"NumeroCotizacion","label":"Número","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_2-of-12 ","size":{"isResponsive":false,"default":"2"}},"elementLabel":"NumeroCotizacion","key":"element_element_block_0_0_outputField_1_0","parentElementKey":"element_block_0_0","userUpdatedElementLabel":true},{"key":"element_element_block_0_0_outputField_2_0","name":"Field","element":"outputField","size":{"isResponsive":false,"default":2},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"","record":"{record}","type":"text","card":"{card}","label":"Origen","fieldName":"Origen"},"type":"element","styleObject":{"size":{"isResponsive":false,"default":2},"sizeClass":"slds-size_2-of-12"},"parentElementKey":"element_block_0_0","elementLabel":"Origen","userUpdatedElementLabel":true},{"name":"Field","element":"outputField","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"","record":"{record}","type":"text","card":"{card}","label":"Estado","fieldName":"ValoresEstado"},"type":"element","styleObject":{"size":{"isResponsive":false,"default":"2"},"sizeClass":"slds-size_2-of-12 "},"elementLabel":"Estado","userUpdatedElementLabel":true,"key":"element_element_block_0_0_outputField_3_0","parentElementKey":"element_block_0_0"},{"name":"EjecutivoPropietario","element":"outputField","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"EjecutivoPropietario","label":"Ejecutivo Propietario","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_2-of-12 ","size":{"isResponsive":false,"default":"2"}},"elementLabel":"EjecutivoPropietario","userUpdatedElementLabel":true,"key":"element_element_block_0_0_outputField_4_0","parentElementKey":"element_block_0_0"},{"key":"element_element_block_0_0_outputField_5_0","name":"Field","element":"outputField","size":{"isResponsive":false,"default":"3"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"","record":"{record}","type":"text","card":"{card}","label":"Corredor","fieldName":"NombreCorredor"},"type":"element","styleObject":{"size":{"isResponsive":false,"default":"3"},"sizeClass":"slds-size_3-of-12 "},"parentElementKey":"element_block_0_0","elementLabel":"Corredor","userUpdatedElementLabel":true}],"elementLabel":"Block-0","styleObjects":[{"key":0,"conditions":"default","styleObject":{"size":{"isResponsive":false,"default":12},"padding":[{"type":"around","size":"small","label":"around:small"}],"class":"slds-border_top slds-border_right slds-border_bottom slds-border_left slds-p-around_small ","sizeClass":"slds-size_12-of-12 ","margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":["border_top","border_right","border_bottom","border_left"],"width":"1","color":"#cccccc","radius":"","style":""},"elementStyleProperties":{},"text":{"align":"","color":""},"inlineStyle":"","style":"     border-top: #cccccc 1px solid;border-right: #cccccc 1px solid;border-bottom: #cccccc 1px solid;border-left: #cccccc 1px solid; \n         "},"label":"Default","name":"Default","conditionString":"","draggable":false}]}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"DataRaptor","value":{"dsDelay":"","bundle":"zrhExtraerCotizacionesDesdeCuenta","bundleType":"","inputMap":{"IdCuenta":"{recordId}"},"jsonMap":"{\"recordId\":\"{recordId}\"}","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"zrhCotizacionesDelHolding","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","lwc":{"DeveloperName":"cfZrhCotizacionesDelHolding_1_Zurich","Id":"0Rb750000000Z64CAE","MasterLabel":"cfZrhCotizacionesDelHolding_1_Zurich","NamespacePrefix":"c","ManageableState":"unmanaged"},"Name":"zrhCotizacionesDelHolding","uniqueKey":"zrhCotizacionesDelHolding_2_Zurich","Id":"0ko8B000000CczKQAS","OmniUiCardKey":"zrhCotizacionesDelHolding/Zurich/2.0","OmniUiCardType":"Parent"};
  export default definition