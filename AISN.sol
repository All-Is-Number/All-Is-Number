// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/**********************************************/
/*     ______   ______   ______   __    __    */
/*    /      \ /      | /      \ /  \  /  |   */
/*   /$$$$$$  |$$$$$$/ /$$$$$$  |$$  \ $$ |   */
/*   $$ |__$$ |  $$ |  $$ \__$$/ $$$  \$$ |   */
/*   $$    $$ |  $$ |  $$      \ $$$$  $$ |   */
/*   $$$$$$$$ |  $$ |   $$$$$$  |$$ $$ $$ |   */
/*   $$ |  $$ | _$$ |_ /  \__$$ |$$ |$$$$ |   */
/*   $$ |  $$ |/ $$   |$$    $$/ $$ | $$$ |   */
/*   $$/   $$/ $$$$$$/  $$$$$$/  $$/   $$/    */
/*                                            */
/**********************************************/

contract AISN is ERC721, Ownable {
    using SafeMath for uint256;
    
    string public constant PROVENANCE = "54109aea993471160613547934f1f338fcf5bdc01fe9a2326c75858f17d724c6";
    uint256 public constant START_AT = 0;
    uint256 public constant MAX_TOKENS = 10000;

    uint256 public constant TRANCHE0 = 420.0 ether;
    uint256 public constant TRANCHE1 = 100.0 ether;
    uint256 public constant TRANCHE2 = 3.0 ether;
    uint256 public constant TRANCHE3 = 1.0 ether;
    uint256 public constant TRANCHE4 = 0.2 ether;
    uint256 public constant TRANCHE5 = 0.0 ether;

    string private _baseTokenURI;

    constructor(string memory baseURI) ERC721("AllIsNumber", "AISN") {
        _baseTokenURI = baseURI;
    }
   
    function mint(uint256[] memory _tokenIds, uint256 _timestamp, bytes memory _signature) public payable {
        require(_tokenIds.length <= 5, "Limit exceeded");

        uint256 totalPrice = 0;
        for(uint8 i = 0; i < _tokenIds.length; i++) {
            totalPrice += priceOf(_tokenIds[i]);
        }
        require(msg.value >= totalPrice, "Value error");
        
        address sender = _msgSender();
        address signer = ECDSA.recover(keccak256(abi.encode(sender, _tokenIds, _timestamp)), _signature);
        require(signer == owner(), "Sig error");
        require(block.timestamp <= _timestamp, "Timeout");

        for(uint8 i = 0; i < _tokenIds.length; i++) {
            require(_tokenIds[i] < MAX_TOKENS);
            _safeMint(sender, _tokenIds[i]);
        }
    }

    function priceOf(uint256 tokenId) public pure returns (uint256) {
        if (tokenId == 0) return TRANCHE0;
        else if (tokenId == 1) return TRANCHE1;
        else if (tokenId < 10) return TRANCHE2;
        else if (tokenId < 100) return TRANCHE3;
        else if (tokenId < 1000) return TRANCHE4;
        return TRANCHE5;
    }

    // The following functions are to set baseURI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    // The following function is for owner
    function withdraw() public onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }
}
