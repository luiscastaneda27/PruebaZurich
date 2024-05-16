(function() {
    
  window.passwordComplexity = function (pass) {
    const regex = /(?=.*[a-z])(?=.*\d)[a-z\d]{8}$/;
    return regex.test(pass);
  }

  window.passwordStrong = function (pass) {
    const strongPassword = /(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8})/;
    return strongPassword.test(pass);
  }

  window.passwordMedium = function (pass) {
    const mediumPassword = /(?=.*[a-z])(?=.*[0-9])(?=.{8})/;
    return mediumPassword.test(pass);
  }


  window.emailValidation = function (pass) {
    const regex = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
    return regex.test(pass);
  }

  window.expRegAlpha = function (pass) {
    const regex = /^[a-zA-ZÃ Ã¡Ã¢Ã¤Ã£Ã¥Ä…ÄÄ‡Ä™Ã¨Ã©ÃªÃ«Ä—Ä¯Ã¬Ã­Ã®Ã¯Å‚Å„Ã²Ã³Ã´Ã¶ÃµÃ¸Ã¹ÃºÃ»Ã¼Å³Å«Ã¿Ã½Å¼ÅºÃ±Ã§ÄÅ¡Å¾Ã€ÃÃ‚Ã„ÃƒÃ…Ä„Ä†ÄŒÄ–Ä˜ÃˆÃ‰ÃŠÃ‹ÃŒÃÃŽÃÄ®ÅÅƒÃ’Ã“Ã”Ã–Ã•Ã˜Ã™ÃšÃ›ÃœÅ²ÅªÅ¸ÃÅ»Å¹Ã‘ÃŸÃ‡Å’Ã†ÄŒÅ Å½âˆ‚Ã° '-]+$/u;
    return regex.test(pass);
  }

  window.phoneFormat = function (pass) {
    const regex = /^([0-9]{9})+$/;
    return regex.test(pass);
  }

  window.isNumeric = function (pass) {
    const regex = "^[0-9]*$";
    return regex.test(pass);
  }

  window.checkRut = function (rut) {

    let rtnValidate = false;

    if (rut.toString().trim() != '' && rut.toString().indexOf('-') > 0) {

      let characters = new Array();
      let serie = new Array(2, 3, 4, 5, 6, 7);
      let dig = rut.toString().substr(rut.toString().length - 1, 1);
      rut = rut.toString().substr(0, rut.toString().length - 2);

      for (let i = 0; i < rut.length; i++) {
          characters[i] = parseInt(rut.charAt((rut.length - (i + 1))));
      }

      let sum = 0;
      let k = 0;
      let remainder = 0;

      for (let j = 0; j < characters.length; j++) {
          k = (k == 6) ? 0 : k;
          sum += parseInt(characters[j]) * parseInt(serie[k]);
          k++;
      }

      remainder = sum % 11;
      let dv = 11 - remainder;

      dv = (dv == 10) ? "k" : dv;
      dv = (dv == 11) ? 0 : dv;

      rtnValidate = (dv.toString().trim().toUpperCase() == dig.toString().trim().toUpperCase()) ? true : false;
    }
    return rtnValidate;
  }

})();