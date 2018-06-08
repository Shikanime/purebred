pragma solidity ^0.4.15;

contract FamilyTree {
    address owner;

    // Race informations

    bytes18 race;
    int128 nextNodeId;
    int128 numberOfFamilymembers;

    // Dog

    mapping (int128 => FamilyNode) familyNodes;

    struct FamilyNode {
        int128 nodeId;
        bytes18 name;
        bytes6 gender;
        int128 dateOfBirth;
        int128 dateOfDeath;
        int128[] parentIds;
        uint noOfChildren;
        int128[] childrenIds;
    }

    // Loggers

    event FamilyCreated(address fromAddress, bytes18 name);
    event FamilyMemberAdded(address fromAddress, bytes18 name, bytes6 gender);

    // Tree initializer
    constructor(bytes18 name, bytes6 gender, int128 dateOfBirth) public payable {
        owner = msg.sender;
        nextNodeId = 1;
        numberOfFamilymembers = 1;
        int128[] memory childrenIds;
        int128[] memory parentIds;
        FamilyNode memory node = FamilyNode(
            0,
            name,
            gender,
            dateOfBirth,
            0,
            parentIds,
            0,
            childrenIds
        );
        familyNodes[0] = node;
        emit FamilyCreated(owner, name);
    }

    // Add dog to tree
    function addFamilyMember(bytes18 name, bytes6 gender, int128 dateOfBirth, int128 dateOfDeath) public returns (int128 id) {
        FamilyNode storage node = familyNodes[nextNodeId];
        node.name = name;
        node.gender = gender;
        node.dateOfBirth = dateOfBirth;
        node.dateOfDeath = dateOfDeath;
        node.noOfChildren = 0;
        emit FamilyMemberAdded(msg.sender, name, gender);
        numberOfFamilymembers++;
        return nextNodeId++;
    }

    // Remove dog to tree
    function deleteFamilyMember(int128 id) public returns (bool) {
        FamilyNode memory fn = familyNodes[id];
        for (uint i = 0; i < fn.parentIds.length; i++) {
            int128 parentId = fn.parentIds[i];
            removeThisChild(parentId, id);
        }
        for (uint c = 0; c < fn.childrenIds.length; c++) {
            int128 childId = fn.childrenIds[c];
            removeThisParent(childId, id);
        }
        delete(familyNodes[id]);
        return true;
    }

    // Infomrations getters

    function getNumberOfFamilyMembers() public view returns (int128) {
        return numberOfFamilymembers;
    }

    function getName(int128 id) public view returns (bytes18) {
        FamilyNode memory fn = familyNodes[id];
        return fn.name;
    }

    function getNode(int128 id) public view returns (
        bytes18 name,
        bytes6 gender,
        int128 dateOfBirth,
        int128 dateOfDeath,
        uint noOfChildren) {
        FamilyNode memory fn = familyNodes[id];
    
        return (
            fn.name,
            fn.gender, 
            fn.dateOfBirth,
            fn.dateOfDeath,
            fn.noOfChildren);
    }

    // Childs table parser

    // Childs informations and methods

    function hasThisChild(int128 parentId, int128 childId) private view returns (bool) {
        FamilyNode memory familyNode = familyNodes[parentId];
        uint length = familyNode.noOfChildren;
        for ( uint i = 0; i < length; i++ ) {
            if (familyNode.childrenIds[i] == childId) {
                return true;
            }
        }
        return false;
    }

    function addChild(int128 parentId, bytes18 name, bytes6 gender, int128 dateOfBirth,int128 dateOfDeath) public {
        int128 id = addFamilyMember(name, gender, dateOfBirth, dateOfDeath);
        FamilyNode storage fn = familyNodes[parentId];
        if (!hasThisChild(parentId, id)) {
            fn.childrenIds.push(id);
            fn.noOfChildren += 1;
            familyNodes[id].parentIds.push(parentId);
        }

    }

    function removeThisChild(int128 parentId, int128 childId) private returns (bool) {
        FamilyNode memory familyNode = familyNodes[parentId];
        uint length = familyNode.noOfChildren;
        for ( uint i = 0; i < length; i++ ) {
            if (familyNode.childrenIds[i] == childId) {
                familyNodes[parentId].childrenIds[i] = -1;
                return true;
            }
        }
        return false;
    }

    // Parents informations and methods

    function removeThisParent(int128 childId, int128 parentId) private returns (bool) {
        FamilyNode memory familyNode = familyNodes[childId];
        
        for ( uint i = 0; i < familyNode.parentIds.length; i++ ) {
            if (familyNode.parentIds[i] == parentId) {
                familyNodes[childId].parentIds[i] = -1;
                return true;
            }
        }
        return false;
    }

    // Add Father to child
    function addFather(int128 childId, bytes18 name, bytes6 gender, int128 dateOfBirth,int128 dateOfDeath) public {
        int128 id = addFamilyMember(name, gender, dateOfBirth, dateOfDeath);
        familyNodes[childId].parentIds.push(id);
        familyNodes[id].childrenIds.push(childId);

    }
    // Add Mother to child
    function addMother(int128 childId, bytes18 name, bytes6 gender, int128 dateOfBirth,int128 dateOfDeath) public {
        int128 id = addFamilyMember(name, gender, dateOfBirth, dateOfDeath);
        familyNodes[childId].parentIds.push(id);
        familyNodes[id].childrenIds.push(childId);
    }

    // And if he die...
    function funeral(int128 id, int128 dateOfDeath) public {
        familyNodes[id].dateOfDeath = dateOfDeath;
    }
}
