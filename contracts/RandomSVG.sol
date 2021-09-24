// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract RandomSVG is ERC721URIStorage, VRFConsumerBase {

  bytes32 public keyHash;
  uint256 public fee;
  uint256 public tokenCounter;

  mapping(bytes32 => address) public requestIdToSender;
  mapping(bytes32 => uint256) public requestIdToTokenId;
  mapping(uint256 => uint256) public tokenIdToRandomNumber;

  event requestedRandomSVG(bytes32 indexed requestId, uint256 indexed tokenId);
  event CreatedUnfinishedRandomSVG(uint256 indexed tokenId, uint256 indexed randomNumber);
  event CreatedRandomSVG(uint256 indexed tokenId, string tokenURI);
  
  constructor(address _VRFCoordinator, address _LinkToken, bytes32 _keyHash, uint256 _fee)
    VRFConsumerBase(_VRFCoordinator, _LinkToken)
    ERC721("RandomSVG", "rsNFT") {
    fee = _fee;
    keyHash = _keyHash;
    tokenCounter = 0;
  }

  function create() public returns (bytes32 requestId) {
    requestId = requestRandomness(keyHash, fee);
    requestIdToSender[requestId] = msg.sender;
    uint256 tokenId = tokenCounter;
    requestIdToTokenId[requestId] = tokenId;
    tokenCounter = tokenCounter + 1;
    emit requestedRandomSVG(requestId, tokenId);
  }

  function fulfillRandomness(bytes32 requestId, uint256 randomNumber) internal override {
    address nftOwner = requestIdToSender[requestId];
    uint256 tokenId = requestIdToTokenId[requestId];
    _safeMint(nftOwner, tokenId);
    tokenIdToRandomNumber[tokenId] = randomNumber;
    emit CreatedUnfinishedRandomSVG(tokenId, randomNumber);
  }

  function finishMint(uint256 _tokenId) public {
    require(bytes(tokenURI(_tokenId)).length <= 0, "tokenURI is already all set!");
    require(tokenCounter > _tokenId, "TokenId has not been minted yet!");
    require(tokenIdToRandomNumber[_tokenId] > 0, "Need to wait for Chainlink VRF");
    uint256 randomNumber = tokenIdToRandomNumber[_tokenId];
    string memory svg = generateSVG(randomNumber);
    string memory imageURI = svgToImageURI(svg);
    string memory tokenURI = formatTokenURI(imageURI);
    _setTokenURI(_tokenId, tokenURI);
    emit CreatedRandomSVG(_tokenId, tokenURI);
  }
}
