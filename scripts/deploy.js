(async () => {
    try{
    const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to: ", nftContract.address);

    // Call the function.
    let txn = await nftContract.makeAnEpicNFT();
    // Wait for it to be minted
    await txn.wait();
    console.log("Minted NFT #1");

    txn = await nftContract.makeAnEpicNFT();
    // Wait for it to be minted
    await txn.wait();
    console.log("Minted NFT #2");
    process.exit(0);
    }
    catch(error) {
        console.log(error)
        process.exit(1);
    }
})()