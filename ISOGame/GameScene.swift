//
//  GameScene.swift
//  ISOGame
//
//  Created by Константин Хомченко on 15.10.2017.
//  Copyright © 2017 Константин Хомченко. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var mainCamera = SKCameraNode()
    var mouse = CGPoint.zero
    var touch = false

    var player : SKSpriteNode!
    var ground : SKTileMapNode!
    var bottom : SKTileMapNode!
    var center : SKTileMapNode!
    var top    : SKTileMapNode!

    var offset : CGFloat!
    var atlas  : SKTextureAtlas!

    var container : SKSpriteNode!
    
    // Форма физического тела нашей плитки
    var bodyPath: CGPath {
        let nsPath = CGMutablePath()
        nsPath.move(to: CGPoint(x: 0, y: -64))
        nsPath.addLine(to: CGPoint(x: -64.0, y: -32.0))
        nsPath.addLine(to: CGPoint(x: 0.0, y: 0.0))
        nsPath.addLine(to: CGPoint(x: 64.0, y: -32.0))
        nsPath.closeSubpath()
        
        return nsPath
    }
    
    // Направление персонажа
    enum Direction : String {
        case Left = "left"
        case Right = "right"
        case Top = "top"
        case Bottom = "bottom"
        case TopLeft = "top-left"
        case TopRight = "top-right"
        case BottomLeft = "bottom-left"
        case BottomRight = "bottom-right"
    }

    override func didMove(to view: SKView) {
        // Основная камера
        self.camera = self.mainCamera
        self.addChild(self.mainCamera)
        
        // Слои карты
        self.ground = self.childNode(withName: "ground") as! SKTileMapNode
        self.bottom = self.childNode(withName: "bottom") as! SKTileMapNode
        self.center = self.childNode(withName: "center") as! SKTileMapNode
        self.top    = self.childNode(withName: "top") as! SKTileMapNode
        
        // Высота основного слоя карты
        self.offset = self.ground.mapSize.height
        
        // Контейнер для плиток карты (опционально)
        // Может понадобится для нахождения пути
        self.container = SKSpriteNode()
        self.addChild(self.container)
        
        // Группа анимации персонажа
        self.atlas = SKTextureAtlas(named: "Player")
        
        // Текстура персонажа по умолчанию
        let deftext = self.atlas.textureNamed("bottom")
        
        // Объект нашего персонажа
        self.player = SKSpriteNode(texture: deftext)
        
        // Физическое тело персонажа, в данном случае круг
        self.player.physicsBody = SKPhysicsBody(circleOfRadius: 25.0, center: CGPoint(x: 0.0, y: -30.0))
        
        // Положение персонажа на карте по умолчанию
        self.player.position = CGPoint(x: -300, y: -100)
        
        // Сброс всех физических параметров персонажа
        self.player.physicsBody?.friction = 0
        self.player.physicsBody?.restitution = 0
        self.player.physicsBody?.linearDamping = 0
        self.player.physicsBody?.angularDamping = 0
        self.player.physicsBody?.allowsRotation = false
        self.player.physicsBody?.affectedByGravity = false
        
        self.addChild(self.player)
        
        // Первый слой карты (снизу)
        let tileBottom = self.tileMapNode(tilemap: self.bottom, level: 0)
        
        // Второй слой карты (по центру)
        let _ = self.tileMapNode(tilemap: self.center, level: 1)
        
        // Третий слой карты (сверху)
        let _ = self.tileMapNode(tilemap: self.top, level: 2)
        
        // Назначаем физические тела плиткам с которыми собираемся сталкиваться
        // Оброщаемся к ним по ссылкам, пришедшим нам в массиве
        for item in tileBottom.enumerated() {
            // Назначаем форму физического тела
            item.element.physicsBody = SKPhysicsBody(polygonFrom: self.bodyPath)
            
            // Сбрасываем все физические параметры объекта
            item.element.physicsBody?.friction = 0
            item.element.physicsBody?.restitution = 0
            item.element.physicsBody?.linearDamping = 0
            item.element.physicsBody?.angularDamping = 0
            item.element.physicsBody?.isDynamic = false
        }
    }

    func touchDown(atPoint pos : CGPoint) {
        // Записываем первое вхождение курсора
        self.mouse = pos
        
        // Говорим что произошло нажатие курсора
        self.touch = true
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        // Обновляем позицию курсора при перемещении
        self.mouse = pos
    }
    
    func touchUp(atPoint pos : CGPoint) {
        // Говорим что курсор отпустили
        self.touch = false
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    // Создание плиток слоя карты для дальнейшей работы с ними
    func tileMapNode(tilemap: SKTileMapNode, level: Int) -> [SKSpriteNode] {
        var array = [SKSpriteNode]()
        
        for col in 0..<tilemap.numberOfColumns {
            for row in 0..<tilemap.numberOfRows {
                let definition = tilemap.tileDefinition(atColumn: col, row: row)
                
                guard let texture = definition?.textures.first else { continue }
                
                let sprite = SKSpriteNode(texture: texture)
                sprite.position = tilemap.centerOfTile(atColumn: col, row: row)
                sprite.zPosition = self.offset - sprite.position.y + tilemap.tileSize.height *  CGFloat(level)
                self.container.addChild(sprite)
                
                array.append(sprite)
            }
        }
        
        tilemap.isHidden = true
        
        return array
    }
    
    // Вычесляем положение персонажа по радиусу относительно позиции курсора (8 положений)
    func angleDirection(_ y: CGFloat, _ x: CGFloat) -> Direction {
        let radius = atan2(y, x) * (180 / CGFloat.pi)
        let angle  = CGFloat(90 / 4)
        
        switch radius {
        case let r where r < angle && r > -angle:
            return Direction.Right
        case let r where r > angle && r < angle * 3:
            return Direction.TopRight
        case let r where r > angle * 3 && r < angle * 5:
            return Direction.Top
        case let r where r > angle * 5 && r < angle * 7:
            return Direction.TopLeft
        case let r where r > angle * 7 || r < -(angle * 7):
            return Direction.Left
        case let r where r > -(angle * 7) && r < -(angle * 5):
            return Direction.BottomLeft
        case let r where r > -(angle * 5) && r < -(angle * 3):
            return Direction.Bottom
        case let r where r > -(angle * 3) && r < -angle:
            return Direction.BottomRight
        default: break
        }
        
        return Direction.Bottom
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Начальная позиция основной камеры
        let oldCamPos = self.mainCamera.position
        
        // Назначаем позицию основной камеры равной позиции персонажа
        self.mainCamera.position = self.player.position
        
        // Новая позиция основной камеры
        let newCamPos = self.mainCamera.position
        
        // Обновляем позиционирование персонажа относительно высоте основного слоя карты
        self.player.zPosition = self.offset - self.player.position.y
        
        // Обновляем позицию курсора относительно позиции основной камеры
        // ЕСЛИ КТО ТО ЗНАЕТ РОДНОЙ МЕТОД ОБНОВЛЕНИЯ КУРСОРА ПОДОБНЫЙ mouseDragged НАПИШИТЕ МНЕ НА ПОЧТУ webkostya@icloud.com ;~)
        self.mouse = CGPoint(x: self.mouse.x + (newCamPos.x - oldCamPos.x), y: self.mouse.y + (newCamPos.y - oldCamPos.y))
        
        // Если курсор зажат
        if self.touch {
            // Получаем положение персонажа
            let direction = self.angleDirection(self.mouse.y - self.player.position.y, self.mouse.x - self.player.position.x)
            
            // Обновляем текстуру персонажа
            self.player.texture = self.atlas.textureNamed(direction.rawValue)

            // Скорость передвижения персонажа
            let speed : CGFloat = 150
            
            // Направление скорости по умолчанию
            var velocity = CGVector(dx: 0, dy: 0)
            
            // Обновляем направление скорости относительно положения персонажа
            switch direction {
            case .Top: velocity = CGVector(dx: 0, dy: speed)
            case .Left: velocity = CGVector(dx: -(speed + speed / 2), dy: 0)
            case .Right: velocity = CGVector(dx: speed + speed / 2, dy: 0)
            case .Bottom: velocity = CGVector(dx: 0, dy: -speed)
            case .TopLeft: velocity = CGVector(dx: -speed, dy: speed)
            case .TopRight: velocity = CGVector(dx: speed, dy: speed)
            case .BottomLeft: velocity = CGVector(dx: -speed, dy: -speed)
            case .BottomRight: velocity = CGVector(dx: speed, dy: -speed)
            }
            
            // Передвигаем персонажа
            self.player.physicsBody?.velocity = velocity
        } else {
            // Останавливаем персонажа
            self.player.physicsBody?.velocity = .zero
        }
    }
}
