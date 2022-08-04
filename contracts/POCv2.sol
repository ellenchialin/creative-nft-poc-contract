// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CreativeNFTPOC is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {

    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string public baseURI;

    constructor() ERC721("CreativeNFTPOCv2", "POC") {
        baseURI = "ipfs://QmPjvTEdoRWH3jZCHQJ72c5QEig7t4Czd1HAzBSjpRGCjr/";
    }

    mapping (uint256 => string) private _tokenURIs;
    mapping(uint256 => bytes32) public idToSeed;

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = baseURI;
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, tokenId.toString()));
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function calcSeed() internal view returns(bytes32) {
        bytes32 seed = sha256(abi.encodePacked(msg.sender, block.timestamp));
        return seed;
    }

    function getSeed(uint256 _tokenId) public view returns(bytes32) {
        return idToSeed[_tokenId];
    }

    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    function mint(string memory uri)
        public
    {
        // Get current tokenId
        uint256 newItemId = _tokenIds.current();

        // Calc seed & add it to the mapping
        bytes32 _seed = calcSeed();
        idToSeed[newItemId] = _seed;

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, uri);

        // Increment currrent tokenId for next one
        _tokenIds.increment();
    }
    
}