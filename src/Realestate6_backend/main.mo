import Prim "mo:prim";
import Principal "mo:base/Principal";
import Text "mo:base/Text";
import Array "mo:base/Array";

actor RealEstateDapp {

  type NFT = {
    tokenId: Nat;
    owner: Principal;
    metadata: Text;
  };

  type Property = {
    id: Nat;
    name: Text;
    owner: Principal;
    description: Text;
    price: Nat;
  };

  var nftTokens : [NFT] = [];
  var properties : [Property] = [];

  public shared(msg) func createNFT(metadata: Text): async NFT {
    let tokenId = nftTokens.size() + 1;
    let nft : NFT = {
      tokenId = tokenId;
      owner = msg.caller;
      metadata = metadata;
    };
    nftTokens := Array.append<NFT>(nftTokens, [nft]);
    return nft;
  };

  public shared(msg) func transferNFT(tokenId: Nat, newOwner: Principal): async Bool {
    if (tokenId > 0 and tokenId <= nftTokens.size()) {
      let index = tokenId - 1;
      if (nftTokens[index].owner == msg.caller) {
        let updatedNFT : NFT = {
          tokenId = nftTokens[index].tokenId;
          owner = newOwner;
          metadata = nftTokens[index].metadata;
        };
        nftTokens := Array.tabulate<NFT>(nftTokens.size(), func(i : Nat) : NFT {
          if (i == index) updatedNFT else nftTokens[i]
        });
        return true;
      }
    };
    return false;
  };

  public shared(msg) func createProperty(name: Text, description: Text, price: Nat, tokenId: Nat): async (Property, Text) {
    let propertyId = properties.size() + 1;
    let property : Property = {
      id = propertyId;
      name = name;
      owner = msg.caller;
      description = description;
      price = price;
    };
    properties := Array.append<Property>(properties, [property]);

    var metadata: Text = "";
    if (tokenId > 0 and tokenId <= nftTokens.size()) {
      metadata := "Owner: " # Principal.toText(nftTokens[tokenId - 1].owner) # ", Metadata: " # nftTokens[tokenId - 1].metadata;
    };

    return (property, metadata);
  };

  public query func listProperties(): async [Property] {
    return properties;
  };

  public shared(msg) func transferProperty(propertyId: Nat, newOwner: Principal): async Bool {
    if (propertyId > 0 and propertyId <= properties.size()) {
      let index = propertyId - 1;
      if (properties[index].owner == msg.caller) {
        let updatedProperty : Property = {
          id = properties[index].id;
          name = properties[index].name;
          owner = newOwner;
          description = properties[index].description;
          price = properties[index].price;
        };
        properties := Array.tabulate<Property>(properties.size(), func(i : Nat) : Property {
                    if (i == index) updatedProperty else properties[i]
        });
        return true;
      }
    };
    return false;
  };
};
