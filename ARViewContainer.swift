////
//  ViewController.swift
//  ARPractice
//
//  Created by CEDAM21 on 10/04/24.
//

import UIKit
import RealityKit
import ARKit
import SwiftUI

//  DEFINIMOS EL VIEW DE LA CLASE "ARViewContainer"
struct ARViewContainer: View {
    var body: some View {
        ARViewControllerRepresentable()
            .edgesIgnoringSafeArea(.all)
    }
}

//  SE DEFINE LA REPRESENTACIÓN DEL CONTROLADOR
struct ARViewControllerRepresentable: UIViewControllerRepresentable {
//  SE DEFINE LA FUNCIÓN QUE RETORNA UN "ViewController", ESTO GENERA LA UI
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController()   // SE HACE UNA INSTANCIA DE LA CLASE CREADA
        return viewController                   // SE RETORNA LA INSTANCIA DE LA CLASE
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}

//  CLASE PARA CREAR NUESTRA APP DE REALIDAD AUMENTADA
class ViewController: UIViewController, ARSessionDelegate {
    
//  SE CREA UNA VARIABLE DE LA CLASE ARView PARA PODER USAR SUS MÉTODOS Y ATRIBUTOS
    private var arView: ARView = {
         let arView = ARView(frame: .zero)
         return arView
     }()

//  SE HACE UN OVERRIDE DE LA FUNCIÓN viewDidLoad(), ESTO GENERA LA VISTA SI SE CARGA CORRECTAMENTE:
/*
    El método viewDidLoad() es un método de ciclo de vida de la clase UIViewController en UIKit.
    Se llama automáticamente después de que se ha cargado completamente la vista principal de un 
    UIViewController desde un archivo de interfaz (como un Storyboard o un XIB) o después de que
    se ha creado programáticamente.
*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // SE OBTIENE EL DELEGATE DE LA SESIÓN PARA PODER MANIPULAR EVENTOS Y NOTIFICACIONES DE LA SESIÓN ARKit
        // ESTO PERMITE MANEJAR LA DETECCIÓN DE PLANOS O LA MANIPULACIÓN DE ANCLAJES:
        arView.session.delegate = self
        
        // SE CONFIGURA AUTOMATICAMENTE LA SESIÓN CON UNA CONFIGURACIÓN PERSONALIZADA
        arView.automaticallyConfigureSession = true
        // SE CREA UNA INSTACIA DE ARWorldTrackingConfiguration PARA EL SEGUIMIENTO DEL MUNDO REAL
        let configuration = ARWorldTrackingConfiguration()
        
        // SE HABILITA LA DETECCIÓN DE PLANOS Y TEXTURAS
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        // SE INICIA LA SESIÓN ARView CON LA CONFIGURACIÓN QUE SE ACABA DE CREAR
        arView.session.run(configuration)
        
        // SE AGREGA LA DETECCIÓN DE TOQUES EN LA PANTALLA Y SE MANDA A LLAMAR A LA FUNCIÓN handleTap POR CADA TOQUE EN PANTALLA
        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:))))
        
        // AGREGAMOS LA VISTA arView COMO UNA SUBVISTA DE LA PRINCIPAL DEL VIEW CONTROLLER
        // ESTO HACE QUE LA VISTA DE AR SE MUESTRE EN LA PANTALLA Y FORME PARTE DE LA JERARQUIA DE VISTAS
        view.addSubview(arView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // CONFIGURANDO LOS CONSTRAINTS DE arView:
        arView.frame = view.bounds
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer){
        let tapLocation = recognizer.location(in: arView)
        
        let result = arView.raycast(from: tapLocation, allowing: .estimatedPlane, alignment: .horizontal)
        
        if let firstResult = result.first {
            let worldPos = simd_make_float3(firstResult.worldTransform.columns.3)
            
            let box = createBox()
            placeObject(object: box, location: worldPos)
        }
    }
    
    func createBox() -> ModelEntity{
//        1. Crear un modelo
        let box = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        
//        2. Agregar material al modelo
        let material = SimpleMaterial(color: .blue, roughness: 0.5, isMetallic: true)
        let mass: Float = 1.0
    
        let entity = ModelEntity(mesh: box, materials: [material])
        
        entity.physicsBody = .init(massProperties: .init(mass: mass), material: nil, mode: .dynamic)
        entity.physicsMotion = .init()
        
        let collisionShape = ShapeResource.generateBox(size: SIMD3(x: 0.1, y: 0.1, z: 0.1))
        entity.collision = .init(shapes: [collisionShape], mode: .default, filter: .default)
        
        return entity
    }
    
    func placeObject(object: ModelEntity, location: SIMD3<Float>){
        var newLocation = location
        newLocation.y += 0.5
        
        let anchor = AnchorEntity(world: newLocation)
        
        anchor.addChild(object)
        arView.scene.addAnchor(anchor)
    }
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]){
        for anchor in anchors {
            if let planeAnchor = anchor as? ARPlaneAnchor {
//                Entidad
                let extent = planeAnchor.extent
                let planeMesh = MeshResource.generatePlane(width: extent.x, depth: extent.z)
                let material = SimpleMaterial(color: .clear, isMetallic: false)
                
                let planeEntity = ModelEntity(mesh: planeMesh, materials: [material])
                
                let physicBody = PhysicsBodyComponent(massProperties: .default, material: nil, mode: .static)
                planeEntity.components.set(physicBody)
                
                let collisionShape = ShapeResource.generateBox(width: extent.x, height: 0.01, depth: extent.z)
                planeEntity.collision = .init(shapes: [collisionShape], mode: .default, filter: .default)
                
                let anchorEntity = AnchorEntity(anchor: planeAnchor)
                
                anchorEntity.addChild(planeEntity)
                arView.scene.addAnchor(anchorEntity)
            }
        }
    }

}

