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

    //Relacionar una direccion de un centro de salud con su contrato
    mapping(address => address) public CentroSalud_contrato;

    //Ejemplo 1: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
    //Ejemplo 2: 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

    //Array de direcciones que almacene los centros de salud validados
    address [] public direcciones_contratos_salud;

    //Array de las direcciones que soliciten acceso
    address [] Solicitudes;

    //Eventos
    event SolicitudAcceso(address);
    event NuevoCentroValidado(address);
    event NuevoContrato(address, address);

    //Modificador que permita unicamentes la ejecucion de funcion por la OMS
    modifier UnicamenteOMS(address _direccion){
        require(_direccion == OMS, "No tienes permisos para realizar esta funcion.");
        _;
    }

    //Funcion para solicitar acceso al sistema medico
    function SolicitarAcceso() public{
        //Almacenar la direccion en el array de solicitudes
        Solicitudes.push(msg.sender);
        //Emision del evento
        emit SolicitudAcceso(msg.sender);
    }

    //Funcion para visualizar las direcciones que han solicitado este acceso
    function VisualizarSolicitudes() public view UnicamenteOMS(msg.sender) returns( address[] memory){
        return Solicitudes;
    }

    //Funcion para validar nuevos centros de salud que puedan autogestionarse -> Unicamente OMS
    function CentrosSalud(address _centroSalud) public UnicamenteOMS(msg.sender){
        //Asignacion del mestado de validez al centro de salud
        Validacion_CentroSalud[_centroSalud] = true;
        //Emision del evento
        emit NuevoCentroValidado(_centroSalud);
    }
    
    //Funcion que permita crear un contrato inteligente
    function FactoryCentroSalud() public{
        //Filtrado para que unicamente los centro de salud validado sean capaces de ejecutar esta funcion
        require(Validacion_CentroSalud[msg.sender] == true, "No tienes permisos para realizar esta funcion.");
        //Generar un Smart Contract -> Generar su direccion
        address contrato_CentroSalud = address (new CentroSalud(msg.sender));
        //Almacenar la direccion del contrato en el array
        direcciones_contratos_salud.push(contrato_CentroSalud);
        //Relacion entre el centro de salud y su contrato
        CentroSalud_contrato[msg.sender] = contrato_CentroSalud;
        //Emision del evento
        emit NuevoContrato(contrato_CentroSalud, msg.sender);
    }

}

//----------------------------------------------------------------------------------------------------------------
//Contrato autogestionable por el centro de Salud
contract CentroSalud{

    //Direcciones iniciales
    address public DireccionCentroSalud;
    address public DireccionContrato;

    constructor(address _direccion) public {
        DireccionCentroSalud = _direccion;
        DireccionContrato = address(this);
    }

    //Relaciona el hash de la persona con los resultado(diagnostico, Codigo IPFS)
    mapping(bytes32 =>Resultados) ResultadosCOVID;

    //Estructura de los resultado
    struct Resultados{
        bool diagnostico;
        string codigoIPFS;
    }

    //Eventos
    event NuevoResultado(bool, string);

    //Filtrar los funciones a ejecutar por el centro de salud
    modifier UnicamenteCentroSalud(address _direccion){
        require(_direccion == DireccionCentroSalud, "No tienes permisos para ejecutar esta funcion.");
        _;
    }

    //Funcion para emitir un resultado de una prueba de COVID
    function ResultadoPruebaCOVID(string memory _idPersona, bool _resultadoCOVID, string memory _codigoIPFS) public UnicamenteCentroSalud(msg.sender){
        //Hash de la identificacion de la persona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_idPersona));
        //Relacion del hash de la persona con la estructura de resultado
        ResultadosCOVID[hash_idPersona] = Resultados(_resultadoCOVID, _codigoIPFS);
        //Emision de un evento
        emit NuevoResultado(_resultadoCOVID, _codigoIPFS);
    }

    //Funcion  que permita la visualizacion de los resultado
    function VisualizarResultados(string memory _idPersona) public view returns(string memory, string memory){
        //hash de la idPersona
        bytes32 hash_idPersona = keccak256(abi.encodePacked(_idPersona));
        // Retorno de un bool como un string
        string memory resultadoPrueba;

        if(ResultadosCOVID[hash_idPersona].diagnostico == true) {
            resultadoPrueba = "Positivo";
        }
        else {
            resultadoPrueba = "Negativo";
        } 
        return (resultadoPrueba, ResultadosCOVID[hash_idPersona].codigoIPFS);
    }
}