// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
pragma experimental ABIEncoderV2;

contract OMS_COVID{

    //Direccion de la OMS => Owner / Dueño del contrato
    address public OMS;

    //Constructor del contrato
    constructor() public{
        OMS = msg.sender;
    }

    //Mapping para relacionar los centros de salud (direccion/address) con la validez del sistema de gestion
    mapping (address => bool) Validacion_CentroSalud;
}