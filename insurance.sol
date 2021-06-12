// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

/** 
 * @title Insurance
 * @dev Implements travel insurance
 */
contract Insurance {
   
    struct Policy {
        uint premium; // amount of ether paid by customer to obtain policy
        uint indemnity;  // amount of ether given out if policy is hit
        address payable policyOwner;
        string name;
        uint flightNumber;
        string flightDate;
        string departureCity;
        string destinationCity;
        string policyStatus;
        bool isPolicy;
    }

    address payable public insurer;
    
    mapping(address => Policy)private policies;
    address[] private addressList;

    string policyString = "premium:0.001 indemnity:0.02 coverage:hail,flood";
    /** 
     * @dev Create a new insurer.
     */
    constructor() {
        insurer = payable(msg.sender);
    }
    
    function view_available_policy() public view returns(string memory)
    {
        return policyString;
    }
    
    function isPolicyBool(address policyAddress) private view returns(bool policyBool){
        return policies[policyAddress].isPolicy;
    }
    
    modifier premium {
        require(
            msg.value == 1000000000000000,
            "Premium is 0.001 ether. Value is in wei. Need 1000000000000000 wei."
        );
        _;
    }
    
    modifier indemnityInput {
        require(
            msg.value == 20000000000000000,
            "Indemnity is 0.02 ether. Value is in wei. Need 20000000000000000 wei."
        );
        _;
    }
    
    function purchase_policy(string memory passengerName,uint flightNumber, string memory flightDate, string memory departureCity, string memory destinationCity) public payable premium returns (bool){
        if(isPolicyBool(msg.sender)) revert();
        if(!payable(insurer).send(1000000000000000)){
            return false;
        }
        policies[msg.sender].premium = 1;
        policies[msg.sender].indemnity = 20;
        policies[msg.sender].policyOwner = payable(msg.sender);
        policies[msg.sender].name = passengerName;
        policies[msg.sender].flightNumber = flightNumber;
        policies[msg.sender].flightDate = flightDate;
        policies[msg.sender].departureCity = departureCity;
        policies[msg.sender].destinationCity = destinationCity;
        policies[msg.sender].policyStatus = "purchased";
        policies[msg.sender].isPolicy = true;
        addressList.push(msg.sender);
        return true;
    }
    
    function pay_indemnity(address payable policyOwnerAddress)public payable indemnityInput returns (bool) {
        require(msg.sender==insurer,"Not the insurer. Can't view all policies.");
        require(addressList.length>0,"No policies.");
        for(uint i =0;i<addressList.length;i++){
            if(addressList[i]==policyOwnerAddress){
                policies[addressList[i]].policyStatus = "claimed";
                if(!payable(policyOwnerAddress).send(msg.value)){
                    policies[addressList[i]].policyStatus = "purchased";
                    return false;
                }
                return true;
            }
        }
        require(1>2,"Policy Owner Address not found");
        return false;
    }
    
    function view_balance() public view returns(string memory){
        require(isPolicyBool(msg.sender),"Not a policy holder. Purchase policy to view balance.");
        if(bytes(policies[msg.sender].policyStatus).length==7 && keccak256(abi.encodePacked(policies[msg.sender].policyStatus))==keccak256(abi.encodePacked("claimed")))return "Your address has been sent 0.02 ether";
        else if(bytes(policies[msg.sender].policyStatus).length==9 && keccak256(abi.encodePacked(policies[msg.sender].policyStatus))==keccak256(abi.encodePacked("purchased")))return "Your policy has not been claimed. Your balance is 0 ether.";
        return "Your policyStatus is in an indeterminate state.";
    }
    
    function view_purchased_policy() public view returns(uint premiumP,
        uint indemnity,
        address policyOwner,
        string memory name,
        uint flightNumber,
        string memory flightDate,
        string memory departureCity,
        string memory destinationCity,
        string memory policyStatus){
        require(isPolicyBool(msg.sender),"Not a policy holder. Please purchase policy"); 
        Policy memory p = policies[msg.sender];
        
        return (p.premium,p.indemnity,p.policyOwner,p.name,p.flightNumber,p.flightDate,p.departureCity,p.destinationCity,p.policyStatus);
        
    }
    
    function view_all_policies() public view returns(uint[] memory premiums,
        uint[] memory indemnities,
        address[] memory policyOwners,
        string[] memory names,
        uint[] memory flightNumbers,
        string[] memory flightDates,
        string[] memory departureCities,
        string[] memory destinationCities,
        string[] memory policyStatuses){
            require(msg.sender==insurer,"Not the insurer. Can't view all policies.");
            require(addressList.length>0,"No policies.");
            premiums = new uint[](addressList.length);
            indemnities = new uint[](addressList.length);
            policyOwners = new address[](addressList.length);
            names = new string[](addressList.length);
            flightNumbers = new uint[](addressList.length);
            flightDates = new string[](addressList.length);
            departureCities = new string[](addressList.length);
            destinationCities = new string[](addressList.length);
            policyStatuses = new string[](addressList.length);
            
            for(uint i = 0;i<addressList.length;i++){
                premiums[i]=(policies[addressList[i]].premium);
                indemnities[i]=(policies[addressList[i]].indemnity);
                policyOwners[i]=(policies[addressList[i]].policyOwner);
                names[i]=(policies[addressList[i]].name);
                flightNumbers[i]=(policies[addressList[i]].flightNumber);
                flightDates[i]=(policies[addressList[i]].flightDate);
                departureCities[i]=(policies[addressList[i]].departureCity);
                destinationCities[i]=(policies[addressList[i]].destinationCity);
                policyStatuses[i]=(policies[addressList[i]].policyStatus);
            }
            return (premiums,indemnities,policyOwners,names,flightNumbers,flightDates,departureCities,destinationCities,policyStatuses);
        }
}
