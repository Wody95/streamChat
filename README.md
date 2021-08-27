### 스트림 채팅 앱

소켓통신을 이해하고, Stream, InputStream, OutputStream, StreamDelegate를 활용해 채팅 앱을 구현합니다.

프로젝트 구성원 : Wody

진행기간 : 21.08.09. ~ 21.08.20.

https://user-images.githubusercontent.com/44163277/129832359-e3d043c3-a9f5-4c29-9154-bfd02e3007dd.mp4
  
  
  
  
## 🧑‍💻 공부한 내용
### Stream

[`Stream`](https://developer.apple.com/documentation/foundation/stream/)클래스를 이용한 소캣 통신
- [InputStream](https://developer.apple.com/documentation/foundation/inputstream)
- [OutputStream](https://developer.apple.com/documentation/foundation/outputstream)
- [CFStreamCreatePairWithSocketToHost](https://developer.apple.com/documentation/corefoundation/1539739-cfstreamcreatepairwithsockettoho/) 
- [StreamDelegate](https://developer.apple.com/documentation/foundation/streamdelegate)

`Stream`의 공식문서에 따르면 Stream 통신을 Host에 연결하려면 `.getStreamsTo` 메서드를 사용하면 되는데, 이 메서드는 더 이상 사용되지 않는다.

그래서 똑같이 더 이상 사용되지 않지만, 이전 공식문서의 [`Setting Up Socket Streams`](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Streams/Articles/NetworkStreams.html#//apple_ref/doc/uid/20002277-BCIDFCDI)문서에 따라 `CFStreamCreatePairWithSocketToHost`을 사용했다.

### Keyboard Layout에 따른 UI 이슈
Xcode의 Simulator에서는 Keyboard를 toggle하여 화면에 띄우지 않고도 텍스트를 입력할 수 있다.
그래서 레이아웃을 구성할 때 키보드가 View를 가리는 상황을 놓치기 쉬운데, 사용자는 채팅 앱을 이용하면서 대부분 Keyboard 이용하기 때문에 유동적으로 변하는 Layout을 고려해야 한다.

#### 키보드를 내린 상태

![image](https://user-images.githubusercontent.com/44163277/131063621-9f1080d7-962a-4084-a2b0-6e4a206b9164.png)

#### 키보드를 올린 상태

![image](https://user-images.githubusercontent.com/44163277/131063751-df8843f7-c2e6-48b0-89c5-4553cefb84ea.png)

`StreamChatViewController.swift`
```swift
private unowned var bottomConstraint = NSLayoutConstraint()

 private func setupSendMessageView() {
        view.addSubview(sendMessageView)

        sendMessageView.delegate = self
        sendMessageView.snp.makeConstraints { sendView in
            sendView.height.equalTo(70)
            sendView.top.equalTo(tableView.snp.bottom)
            sendView.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }

        bottomConstraint = sendMessageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                                   constant: .zero)
        bottomConstraint.isActive = true
    }
```

해당 `View`의 가장 밑 부분을 담당하는 Layout에 `bottomConstraint`를 붙여준다. 
이렇게 되면 가장 밑부분 View인 `sendMessageView`의 bottom은 superview의 bottom이 아니라 bottomConstraint을 따르게 된다. 

keyboard가 올라오는 크기를 bottomConstraint에 설정해주고, animate를 통해 뷰의 변동을 적용하면, 자연스럽게 View의 크기는 키보드에 맞게 변동된다.

*리뷰어의 피드백 🧐*
```
bottomConstraint에 사용된 unowned는 weak와 어떤차이가 있을까요?
```

> unowned와 weak의 공통점은 인스턴스에 대한 소유권을 주장하지 않고 주소값만 갖고 있다는 점이다.  
> 차이점은 weak는 메모리가 해당 인스턴스의 메모리가 해제될 때 nil로 전환하면서 옵셔널한 값이 될 수 있다는 점이고,  
> unowned는 nil이 될 수 없다는 점이다.  
> 그런 의미에서 bottomConstraint는 뷰의 최하단을 담당하기 때문에 nil로 존재하면 안된다고 생각해서 unowned를 사용했다.
