// SPDX-License-Identifier: UNLICENSED

//version of the Solidity compiler, nothing lower
pragma solidity ^0.8.0;

//import OpenZeppelin Contracts
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

//The NFT standard is known as ERC721 

// We need to import the helper functions from the contract that we copy/pasted.
import { Base64 } from "./libraries/Base64.sol";

// contract class representation
// We inherit the contract we imported
contract MyEpicNFT is ERC721URIStorage{
    // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    // I create three arrays, each with their own theme of random words.
    string[] firstWords = ["Activation", "Flow", "Nuclear", "Operation", "Vacuum", "Radiate", "Operation", "Depth", "Joint", "Gear", "Weld", "Savvy", "Load", "Expert", "Tool"];
    string[] secondWords = ["Artisan", "Clergy", "Anarchy", "Dictator", "Judicial", "Myth", "Schism", "Boycott", "Barter", "Census", "Dynasty", "Neglect", "Nomad", "Pardon", "Poll"];
    string[] thirdWords = ["Border", "Elevation", "Key", "Latitude", "Nation", "River", "Tropics", "West", "Scale", "Region", "Sea", "Mile", "Hemisphere", "Nautical", "East"];

    // MAGICAL EVENTS.
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    //pass the name of our NFTs token and it's symbol.
    constructor() ERC721 ("DirtyBane", "SQUARE") {
        console.log("This is my NFT contract. Whoa!");
    }

    function FirstWord(uint256 tokenId) public view returns (string memory){
        // Seed the random generator
        uint256 rand = random(string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId))));
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function SecondWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId))));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function ThirdWord(uint256 tokenId) public view returns (string memory) {
        uint256 rand = random(string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId))));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public{
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // Randomly grab one word from each of the three arrays.
        string memory first = FirstWord(newItemId);
        string memory second = SecondWord(newItemId);
        string memory third = ThirdWord(newItemId);
        string memory combined = string(abi.encodePacked(first, second, third));

        string memory finalSvg = string(abi.encodePacked(baseSvg, combined, "</text></svg>"));

        // Get all the JSON metadata in place and base64 encode it.
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combined,
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

    // Prepend data:application/json;base64, to our data.
    string memory finalTokenUri = string(
        abi.encodePacked("data:application/json;base64,", json)
    );
        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender.
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data.
        _setTokenURI(newItemId, finalTokenUri);
        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);

        // Increment the counter for when the next NFT is minted.
        _tokenIds.increment();

        // EMIT MAGICAL EVENTS.
        emit NewEpicNFTMinted(msg.sender, newItemId);
    }
}
