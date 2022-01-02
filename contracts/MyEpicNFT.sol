// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.4;

// Import OpenZeppelin Contracts
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

// Import the helper functions from the library contract
import {Base64} from "./libraries/Base64.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods
contract MyEpicNFT is ERC721URIStorage {
    // use what OpenZeppelin gives us to help us keep track of tokenIds
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // The SVG code, need to change the word that is displayed
    // so use a baseSVG variable that all NFTs can use
    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = [
        "CHOCOLATE",
        "CANDY",
        "TRUFFLE",
        "COFFEE",
        "CIDER",
        "BEER",
        "WINE",
        "WATER",
        "JELLO",
        "YOGURT",
        "COCONUT",
        "CHEESE",
        "CHILLI"
    ];

    string[] secondWords = [
        "COLORED",
        "COATED",
        "BAKED",
        "GRILLED",
        "SPRINKLED",
        "SEASONED",
        "FLAVOURED",
        "INFUSED",
        "SHAKEN",
        "STIRRED",
        "FERMENTED",
        "BASTED",
        "ROASTED"
    ];

    string[] thirdWords = [
        "CHICKEN",
        "BEEF",
        "TOFU",
        "DUCK",
        "RABBIT",
        "FISH",
        "PORK",
        "SALMON",
        "QUAIL",
        "GOAT",
        "OX"
    ];

    event NewEpicNFTMinted(address sender, uint256 tokenId);

    // We need to pass the name of our NFTs token and its symbol
    constructor() ERC721("WeirdMealsNFT", "WMNFT") {
        console.log("This is my Weird Meals NFT contract. Look on with growling bellies!");
    }

    function pickRandomFirstWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator
        uint256 rand = random(
            string(abi.encodePacked("FIRST_WORD", Strings.toString(tokenId)))
        );
        // Squash the number between 0 and the length of the array to avoid going out of bounds.
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator
        uint256 rand = random(
            string(abi.encodePacked("SECOND_WORD", Strings.toString(tokenId)))
        );
        // Squash the number between 0 and the length of the array to avoid going out of bounds.
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        // I seed the random generator
        uint256 rand = random(
            string(abi.encodePacked("THIRD_WORD", Strings.toString(tokenId)))
        );
        // Squash the number between 0 and the length of the array to avoid going out of bounds.
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    // A function our user will hit to get their NFT.
    function makeAnEpicNFT() public {
        // Get the current tokenId, this starts at 0.
        uint256 newItemId = _tokenIds.current();

        // grab random word from each of the three arrays
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string(
            abi.encodePacked(first," ", second," ", third)
        );

        //concatenate them together, and close the <text> and <svg> tags
        string memory finalSvg = string(
            abi.encodePacked(baseSvg, combinedWord, "</text></svg>")
        );
        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");

        // Get all the JSON metadata in place and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        combinedWord,
                        '", "description": "A highly acclaimed collection of weird meals.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Like before, we prepend data:application/json;base64 to our data
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(
            string(
                abi.encodePacked(
                    "https://nftpreview.0xdev.codes/?code=",
                    finalTokenUri
                )
            )
        );
        console.log("--------------------\n");

        // Actually mint the NFT to the sender using msg.sender
        _safeMint(msg.sender, newItemId);

        // Set the NFTs data
        _setTokenURI(
            newItemId,
            finalTokenUri        );

        // Increment the counter for when the next NFT is minted
        _tokenIds.increment();

        console.log(
            "An NFT w/ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
        emit NewEpicNFTMinted(msg.sender, newItemId);

    }
}
