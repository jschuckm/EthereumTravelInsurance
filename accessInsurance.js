(async () => {
    // const account1 = '0xC42d437b15d1484B7115d76218c298A1fAAD8cb4'
    
    const contractAddress = '0xdfdB7f7FF04e2351697236a7e47A5EfB5843F8C1'
    console.log('start exec');
    try{
    const txtPath = 'browser/scripts/weather.txt';
    var weather = await remix.call('fileManager','getFile',txtPath);
    console.log(typeof weather);
    console.log(weather);
    weather = weather.split(/[\n\r ]+/);
    console.log(weather);
    var weatherObj = [];
    for(var i = 3;i<weather.length;i++){
        if(i%3==0){
            weatherObj[(i/3)-1]= {};
            weatherObj[(i/3)-1].date=weather[i];
        }else if(i%3==1){
            weatherObj[((i-1)/3)-1].city = weather[i];
        }else if(i%3==2){
            weatherObj[((i-2)/3)-1].weather = weather[i];
        }
    }
    console.log(weatherObj);
    }catch(e){
        console.log(e.message);
    }
    const artifactsPath = `browser/contracts/artifacts/Insurance.json` // Change this for different path
    const metadata = JSON.parse(await remix.call('fileManager', 'getFile', artifactsPath))
    const accounts = await web3.eth.getAccounts()
    
    let contract = new web3.eth.Contract(metadata.abi, contractAddress)
    
    contract.methods.insurer().call(function (err, result) {
        if (err){
            console.log("An error occured", err)
            return
        } else {
            console.log("The result of first query is: ", result)
            console.log('first query finished')
        }
    })
    
    //Asynchronous version
    // contract.methods.store(50).send({from: accounts[0]}, function (err, res) {
    //     if (err) {
    //           console.log("An error occured", err)
    //           return
    //     }
    //     console.log("Hash of the transaction: " + res)
    // })
    try{
        let allPolicies = await contract.methods.view_all_policies().call({from: '0x0A4E9EA0b4288061AA4ba22f0b4aaB4d6d4a63db'})
        console.log(allPolicies);
        var dates = allPolicies[5];
        var locations = allPolicies[6];
        var addresses = allPolicies[2];
        var status = allPolicies["policyStatuses"];
        console.log(dates);
        console.log(locations);
        
        for(var i = 0;i<dates.length;i++){
           for(var j = 0;j<weatherObj.length;j++){
               if(dates[i]==weatherObj[j].date){
                   if(locations[i]==weatherObj[j].city){
                       if(weatherObj[j].weather=="Hail"||weatherObj[j].weather=="Flood"){
                           if(status[i]=="purchased"){
                               console.log("Policy hit need to pay indemnity to "+addresses[i]);
                               contract.methods.pay_indemnity(addresses[i]).send({value:20000000000000000,from:'0x0A4E9EA0b4288061AA4ba22f0b4aaB4d6d4a63db'});
                           }
                       }
                   }
               }
           }
        }
    }catch(e){
        console.log(e.message);
    }
    // try{
    // let result = await contract.methods.purchase_policy("Jared",251,"2/12/21","Des Moines","Ft Lauderdale").send({value:1000000000000000,from: '0x0A4E9EA0b4288061AA4ba22f0b4aaB4d6d4a63db'})
    // console.log("Purchase plicy result: ", result)
    // }catch(e){
    //     console.log(e.message);
    // }
    try{
    let result = await contract.methods.view_purchased_policy().call({from: '0x0A4E9EA0b4288061AA4ba22f0b4aaB4d6d4a63db'})
    console.log(result);
    }catch(e){
        console.log(e.message);
    }
    
    try{
    let result = await contract.methods.view_all_policies().call({from: '0x0A4E9EA0b4288061AA4ba22f0b4aaB4d6d4a63db'});
    console.log(result);
    }catch(e){
        console.log(e.message);
    }
    console.log('exec finished')
    
})()
