// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TipJarV2
 * @dev Contrat pour envoyer des pourboires à des destinataires spécifiques avec des messages
 */
contract TipJarV2 {
    address public owner;
    uint256 public totalTips;
    uint256 public platformFee; // en pourcentage (e.g., 5 = 5%)
    
    struct Tip {
        address sender;
        address recipient;
        uint256 amount;
        string message;
        uint256 timestamp;
    }
    
    Tip[] public tips;
    
    // Mapping pour suivre les soldes des destinataires
    mapping(address => uint256) public recipientBalances;
    uint256 public platformBalance;
    
    event TipSent(
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        string message,
        uint256 timestamp
    );
    
    event FundsWithdrawn(
        address indexed recipient,
        uint256 amount,
        uint256 timestamp
    );
    
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    event PlatformFeeUpdated(
        uint256 oldFee,
        uint256 newFee
    );
    
    constructor() {
        owner = msg.sender;
        platformFee = 5; // 5% par défaut
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "TipJar: caller is not the owner");
        _;
    }
    
    /**
     * @dev Envoie un pourboire à un destinataire spécifique
     * @param _recipient Adresse du destinataire
     * @param _message Message accompagnant le pourboire
     */
    function sendTip(address _recipient, string memory _message) external payable {
        require(msg.value > 0, "TipJar: tip amount must be greater than 0");
        require(_recipient != address(0), "TipJar: invalid recipient address");
        
        // Calcul du montant pour la plateforme et pour le destinataire
        uint256 platformAmount = (msg.value * platformFee) / 100;
        uint256 recipientAmount = msg.value - platformAmount;
        
        // Mise à jour des soldes
        platformBalance += platformAmount;
        recipientBalances[_recipient] += recipientAmount;
        
        // Enregistrement du pourboire
        tips.push(Tip({
            sender: msg.sender,
            recipient: _recipient,
            amount: msg.value,
            message: _message,
            timestamp: block.timestamp
        }));
        
        totalTips++;
        
        emit TipSent(msg.sender, _recipient, msg.value, _message, block.timestamp);
    }
    
    /**
     * @dev Permet à un destinataire de retirer ses fonds
     */
    function withdrawRecipientFunds() external {
        uint256 amount = recipientBalances[msg.sender];
        require(amount > 0, "TipJar: no funds available to withdraw");
        
        recipientBalances[msg.sender] = 0;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "TipJar: withdrawal failed");
        
        emit FundsWithdrawn(msg.sender, amount, block.timestamp);
    }
    
    /**
     * @dev Permet à l'owner de retirer les frais de plateforme
     */
    function withdrawPlatformFees() external onlyOwner {
        uint256 amount = platformBalance;
        require(amount > 0, "TipJar: no platform fees available to withdraw");
        
        platformBalance = 0;
        
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "TipJar: platform fee withdrawal failed");
        
        emit FundsWithdrawn(owner, amount, block.timestamp);
    }
    
    /**
     * @dev Définit un nouveau taux de frais pour la plateforme
     * @param _newFee Nouveau taux de frais (en pourcentage)
     */
    function setPlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 20, "TipJar: fee cannot exceed 20%");
        uint256 oldFee = platformFee;
        platformFee = _newFee;
        
        emit PlatformFeeUpdated(oldFee, _newFee);
    }
    
    /**
     * @dev Transfère la propriété du contrat à une nouvelle adresse
     * @param _newOwner Adresse du nouveau propriétaire
     */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "TipJar: new owner is the zero address");
        address oldOwner = owner;
        owner = _newOwner;
        
        emit OwnershipTransferred(oldOwner, _newOwner);
    }
    
    /**
     * @dev Renvoie tous les pourboires
     */
    function getAllTips() external view returns (Tip[] memory) {
        return tips;
    }
    
    /**
     * @dev Renvoie un pourboire spécifique par son index
     */
    function getTip(uint256 _index) external view returns (
        address sender,
        address recipient,
        uint256 amount,
        string memory message,
        uint256 timestamp
    ) {
        require(_index < tips.length, "TipJar: tip index out of bounds");
        Tip storage tip = tips[_index];
        return (
            tip.sender,
            tip.recipient,
            tip.amount,
            tip.message,
            tip.timestamp
        );
    }
    
    /**
     * @dev Renvoie le nombre de pourboires
     */
    function getTipCount() external view returns (uint256) {
        return tips.length;
    }
    
    /**
     * @dev Renvoie le solde d'un destinataire spécifique
     */
    function getRecipientBalance(address _recipient) external view returns (uint256) {
        return recipientBalances[_recipient];
    }
    
    /**
     * @dev Renvoie le solde total du contrat
     */
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Fonction de repli pour accepter les paiements sans message
     */
    receive() external payable {
        // Considérer le paiement comme un pourboire à l'owner sans message
        platformBalance += msg.value;
    }
}
