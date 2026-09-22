import ToolboxCore

public extension ReduxAction {
    
    func dispatch(into store: App.Store<T>) {
        store.dispatch(action: self)
    }
    
}
