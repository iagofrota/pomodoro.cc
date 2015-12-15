/*@flow*/
import {
  ADD_TODO_SUCCESS,
  DELETE_TODO_SUCCESS,
  GET_TODO_SUCCESS,
  UPDATE_TODO_SUCCESS
} from '../actions/todos'

export default function todos(state:TodoState=[], action:Action):TodoState {
  switch(action.type){
  case GET_TODO_SUCCESS: {
    return action.payload.todos
  }
  case ADD_TODO_SUCCESS: {
    return [
      ...state,
      action.payload
    ]
  }
  case DELETE_TODO_SUCCESS: {
    return state.filter((todo) => {
      return todo.text !== action.payload.text
    })
  }
  case UPDATE_TODO_SUCCESS: {
    return state.map((todo) => {
      return (todo.id !== action.payload.id)
              ? todo
              : action.payload
    })
  }
  }
  return state
}
