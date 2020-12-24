pragma solidity ^0.5.0; 

 interface RegisterSC{
       function getSellerSortingmMachineDetails(address addr) external view returns ( address [] memory); 
    }
    

contract Tracking{
    
    //state variables - stored permanently in contract storage 
    
    string public status;
    address public plasticBottleAddress; // attained by scanning the QR code
    address public caller; 
     
    //variables for counting plastic bottles scanned in the sorting machine 
    uint256 public bottlesSortedCounter; 
    uint256 public bottlesSortedLimit; 
    address [] public plasticBale; 
    
    
     //constructor - initilize state variables
    constructor() public{
        status = 'NoStatus'; 
        caller = msg.sender; // address of the current caller
        bottlesSortedCounter = 0;
    }
    
    //events
    event updateStatusMachine(address plasticBottleAddress, string status, uint time); 
    event updateStatusRecycler(address recycler, address plasticBottleAddress, string status, uint time);
    event plasticBaleCompleted(address [] plasticBale, uint time ); 
    
    
    modifier sortingMachineOnly (address registerContractAddr, address sellerAddr){
        
        address[] memory tempArray; 

       RegisterSC registerSC = RegisterSC(registerContractAddr); //pass contract address 
       tempArray = registerSC.getSellerSortingmMachineDetails(sellerAddr); // pass address of sorting facility-seller
      
      
       for(uint256 i=0; i< tempArray.length; i++){ //only registered sorting machines can update the status of the bottle 
       
         if (caller == tempArray[i])
          _;
          
       }
        
   }
   
  
    function setBottleAddress (address _plasticBotttleAddress) public {  // Paramenter is the scanned address on the bottle
        plasticBottleAddress = _plasticBotttleAddress; 
        
    }
    
    function setBottlesSortedLimit (uint256 _bottlesSortedLimit) public {  // Can be changed based on the sorting facility production goals 
        bottlesSortedLimit = _bottlesSortedLimit;
        
    }
    
    function updateStatusDisposed () public{
        status = 'disposed'; 
          emit updateStatusRecycler (caller, plasticBottleAddress, status, now);
    }
    
    function updateStatusSorted (address registerContractAddr, address sellerAddr) public sortingMachineOnly (registerContractAddr, sellerAddr){
        
       plasticBale.push(plasticBottleAddress);
       bottlesSortedCounter++;
       status = 'sorted';
       
       emit updateStatusMachine(plasticBottleAddress, status, now);
      
      
      if(bottlesSortedCounter == bottlesSortedLimit )
         announcePlasticBaleCompleted(); 
      
    }
    
    function announcePlasticBaleCompleted() internal {
         bottlesSortedCounter =0; 
         emit plasticBaleCompleted (plasticBale, now); 
        
    }
    
}