import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from 'vlocity_ins/omniscriptBaseMixin';

export default class Zrh_GestionarSobreprima  extends OmniscriptBaseMixin(LightningElement) {
// create option relation Schip
optionsRelationFamily =  [{
                            "value": "Titular",
                            "label": "Titular",

                          },

                          {
                            "value": "Hijo/a",
                            "label": "Hijo/a",

                          },

                          {
                            "value": "Hijo Duplos",
                            "label": "Hijo Duplos",

                          },
                          {
                            "value": "Cónyuge",
                            "label": "Cónyuge",

                          },
                          {
                            "value": "Beneficiario",
                            "label": "Beneficiario",

                          },
                          {
                            "value": "Empresa",
                            "label": "Empresa",

                          },

                          {
                            "value": "Hijastro (a)",
                            "label": "Hijastro (a)",

                          },

                          {
                            "value": "Nieto",
                            "label": "Nieto",

                          },
                          {
                            "value": "Otros",
                            "label": "Otros",

                          },
                          {
                            "value": "Padres",
                            "label": "Padres",

                          },
                          {
                            "value": "Sobrino (a)",
                            "label": "Sobrino (a)",

                          },
                          {
                            "value": "Conviviente Civil",
                            "label": "Conviviente Civil",

                          }];
  @api familylist = [];
  @api cantfamily;
  @api hasError = false;
  optionsFamily = this.optionsRelationFamily;
  familyExist = true;
  @track activeSections = [0, 1, 2, 3, 4];
  buttonsParameters = { label: '', value: '', tittle: '' };
  blockFamilyEmpty;
  addBtnFamily = true;
  delBtnFamily = false;
  @track listReferencesFamily = [];
  listReferenciesFamilyDelete = [];
  listReferenciesDelete = [];

  //method that manages the validation of the fields whose class is inputFieldCustom
  @api checkValidity() {
    let isSelfValidated = false;
    isSelfValidated = [
      ...this.template.querySelectorAll(".inputFieldCustom")
    ].reduce((validSoFar, inputField) => {
      inputField.reportValidity();
      return validSoFar && inputField.checkValidity();
    }, true);

    if (this.hasError==true){
      isSelfValidated = false;

    }
    return isSelfValidated;
  }

  connectedCallback() {
    this.loadInitialEmptyBlocks("Todas");
    this.listReferencesFamily = this.cantfamily > 0 ? JSON.parse(JSON.stringify(this.familylist)) : [].concat(this.blockFamilyEmpty);
    this.familyExist = this.listReferencesFamily.length > 0 ? true : false;
    this.showButton("Familiar");
  }

  // create estructure initial of addicional premium
  loadInitialEmptyBlocks(inicial) {
    let value = inicial;
    switch (value) {
      case "Todas":
        this.blockFamilyEmpty = { parentesco: '', edadSobre: '', porcSobreprima: '', ReferenceType: 'Familiar',required:true, validate: false, addBtn: false, delBtn: false, deleted: false, positionReferenceTitle: 'Sobreprima 1', position: 1 };
      case "Familiar":
        this.blockFamilyEmpty = { parentesco: '', edadSobre: '', porcSobreprima: '', ReferenceType: 'Familiar',required:true,  validate: false, addBtn: false, delBtn: false, deleted: false, positionReferenceTitle: 'Sobreprima 1', position: 1 };
        break;
      default:
        break;
    }
  }

  //manager of add o delete additional Premium
  showButton(referenceType) {
    switch (referenceType) {
      case "Familiar":
        if (this.listReferencesFamily.length == 1) {
         this.listReferencesFamily[0].addBtn = true;
        } else if (this.listReferencesFamily.length == 2) {
          this.listReferencesFamily[0].addBtn = true;
          this.listReferencesFamily[1].delBtn = true;
        } else if (this.listReferencesFamily.length == 3) {
          this.listReferencesFamily[0].addBtn = true;
          this.listReferencesFamily[1].delBtn = true;
          this.listReferencesFamily[2].delBtn = true;
        } else if (this.listReferencesFamily.length == 4) {
          this.listReferencesFamily[0].addBtn = true;
          this.listReferencesFamily[1].delBtn = true;
          this.listReferencesFamily[2].delBtn = true;
          this.listReferencesFamily[3].delBtn = true;
        } else if (this.listReferencesFamily.length == 5) {
          this.listReferencesFamily[0].addBtn = false;
          this.listReferencesFamily[1].delBtn = true;
          this.listReferencesFamily[2].delBtn = true;
          this.listReferencesFamily[3].delBtn = true;
          this.listReferencesFamily[4].delBtn = true;
        }
        break;
      default:
        break;
    }
  }

  //method that is executed at the moment of a value change in the override form, simultaneously fills the blockFamiliar object array node
  handleChangeFamily(event) {
    const valueInput = event.target.value != null ? event.target.value : event.detail.value;
    const labelInput = event.target.name;
    const itemIndex = event.currentTarget.dataset.index;
    if (this.listReferencesFamily[itemIndex][labelInput] != valueInput) {
      this.listReferencesFamily[itemIndex][labelInput] = valueInput;
      if (labelInput == 'parentesco') {
        ////////////////////// logic of repeat relation schip //////////////////////
        let listRelationShipSelectCh = [];
        this.hasError = false;
        this.listReferencesFamily.forEach(lsparentrescoCh => {
          if (lsparentrescoCh.parentesco != '') {
            if (!listRelationShipSelectCh.includes(lsparentrescoCh.parentesco)) {
              listRelationShipSelectCh.push(lsparentrescoCh.parentesco);
            } else {
              this.hasError = true;
            }
          }
        });
      }      
      let myData = {};
      myData = {
        "blockFamiliar": this.listReferencesFamily,
        "hasError": this.hasError
      }
      this.omniApplyCallResp(myData);
      this.omniValidate();
    }
  }

  //method that by reference adds a new blockFamilyEmpty object to the listReferencesFamily array 
  addObjectToList(referenceType) {
    switch (referenceType) {
      case "Familiar":
        this.loadInitialEmptyBlocks("Familiar");
        if (this.listReferenciesFamilyDelete.length > 0) {
          this.listReferencesFamily.push(this.listReferenciesFamilyDelete.pop())
        } else {
          this.blockFamilyEmpty.position = this.listReferencesFamily.length + 1;
          this.listReferencesFamily.push(this.blockFamilyEmpty)
          let position = this.listReferencesFamily.length;
          this.listReferencesFamily[this.listReferencesFamily.length - 1].positionReferenceTitle = `Sobreprima ${position}`
        }
        break;
      default:
        break;
    }
  }

  //method handled by reference and index remove from array listReferencesFamily the object that is in the index  (indexList)
  delObjectFromList(referenceType, indexList) {
    switch (referenceType) {
      case "Familiar":
        this.listReferenciesFamilyDelete.push(this.listReferencesFamily[indexList]);
        this.listReferencesFamily.splice(indexList, 1)
        break;
      default:
        break;
    }
  }
  //method that is executed when the button to add or remove overprime is clicked
  handleClickButton(event) {
    const labelInput = event.currentTarget.dataset.type;
    const labelbuttonadd = event.target.name;
    const itemIndex = event.currentTarget.dataset.index;
    const actionInput = event.target.title;
    switch (labelInput) {
      case "Familiar":
        if (actionInput == "Agregar") {
          this.addObjectToList(labelInput);
          //////////////////// ////////////////////// logic of repeat relation schip //////////////////////////////////////////////////
          this.hasError = false;
          let listRelationShipSelectAdd = [];
          this.listReferencesFamily.forEach(lsparentrescoAdd => {
            if (lsparentrescoAdd.parentesco != '') {
              if (!listRelationShipSelectAdd.includes(lsparentrescoAdd.parentesco)) {
                listRelationShipSelectAdd.push(lsparentrescoAdd.parentesco);
              } else {
                this.hasError = true;
              }
            }
          });
          this.showButton(labelInput);
          let myData = {};
          myData = {
            "blockFamiliar": this.listReferencesFamily,
            "hasError": this.hasError
          }
          this.omniApplyCallResp(myData);
        } else if (actionInput == "Eliminar") {
          this.delObjectFromList(labelInput, itemIndex);
          //////////////////// ////////////////////// logic of repeat relation schip //////////////////////////////////////////////////
          this.hasError = false;
          let listRelationShipSelect = [];
          this.listReferencesFamily.forEach(lsparentresco => {
            if (lsparentresco.parentesco != '') {
              if (!listRelationShipSelect.includes(lsparentresco.parentesco)) {
                listRelationShipSelect.push(lsparentresco.parentesco);
              } else {
                this.hasError = true;
              }
            }
          });
          ////////////////////////////////////////////////////////////////////////
          this.showButton(labelInput);
          let myData = {};
          myData = {
            "blockFamiliar": this.listReferencesFamily,
            "hasError": this.hasError
          }
          this.omniApplyCallResp(myData);
        }
        break;
      default:
        break;
    }
  }
}