/**
 * Copyright (C) 2009-2013 Typesafe Inc. <http://www.typesafe.com>
 */
package actorbintree

import akka.actor._
import scala.collection.immutable.Queue

object BinaryTreeSet {

  trait Operation {
    def requester: ActorRef
    def id: Int
    def elem: Int
  }

  trait OperationReply {
    def id: Int
  }

  /** Request with identifier `id` to insert an element `elem` into the tree.
    * The actor at reference `requester` should be notified when this operation
    * is completed.
    */
  case class Insert(requester: ActorRef, id: Int, elem: Int) extends Operation

  /** Request with identifier `id` to check whether an element `elem` is present
    * in the tree. The actor at reference `requester` should be notified when
    * this operation is completed.
    */
  case class Contains(requester: ActorRef, id: Int, elem: Int) extends Operation

  /** Request with identifier `id` to remove the element `elem` from the tree.
    * The actor at reference `requester` should be notified when this operation
    * is completed.
    */
  case class Remove(requester: ActorRef, id: Int, elem: Int) extends Operation

  /** Request to perform garbage collection*/
  case object GC

  /** Holds the answer to the Contains request with identifier `id`.
    * `result` is true if and only if the element is present in the tree.
    */
  case class ContainsResult(id: Int, result: Boolean) extends OperationReply
  
  /** Message to signal successful completion of an insert or remove operation. */
  case class OperationFinished(id: Int) extends OperationReply

}


class BinaryTreeSet extends Actor {
  import BinaryTreeSet._
  import BinaryTreeNode._

  def createRoot: ActorRef = context.actorOf(BinaryTreeNode.props(0, initiallyRemoved = true))

  var root = createRoot
  
  // optional
  var pendingQueue = Queue.empty[Operation]

  // optional
  def receive = normal

  // optional
  /** Accepts `Operation` and `GC` messages. */
  val normal: Receive = { 
    case BinaryTreeSet.Contains(requester, id, elem) => {
      root ! BinaryTreeSet.Contains(requester, id, elem)
    }
    case BinaryTreeSet.Insert(requester, id, elem) => {
      root ! BinaryTreeSet.Insert(requester, id, elem)
    }
    case BinaryTreeSet.Remove(requester, id, elem) => {
      root ! BinaryTreeSet.Remove(requester, id, elem)
    }
    case GC =>{
      val newRoot = context.actorOf(BinaryTreeNode.props(0, true))
      root ! BinaryTreeNode.CopyTo(newRoot)
      context.become(garbageCollecting(newRoot))
    }
  }

  // optional
  /** Handles messages while garbage collection is performed.
    * `newRoot` is the root of the new binary tree where we want to copy
    * all non-removed elements into.
    */
  def garbageCollecting(newRoot: ActorRef): Receive = {
    case x : BinaryTreeSet.Operation => {
      pendingQueue = pendingQueue.enqueue(x)
    }
    case BinaryTreeNode.CopyFinished => {
      root ! PoisonPill
      while(!pendingQueue.isEmpty){
        val (op, rest) = pendingQueue.dequeue
        newRoot ! op
        pendingQueue = rest
      }
      root = newRoot
      context.become(normal)
    }
  }

}

object BinaryTreeNode {
  trait Position

  case object Left extends Position
  case object Right extends Position

  case class CopyTo(treeNode: ActorRef)
  case object CopyFinished

  def props(elem: Int, initiallyRemoved: Boolean) = Props(classOf[BinaryTreeNode],  elem, initiallyRemoved)
}

class BinaryTreeNode(val elem: Int, initiallyRemoved: Boolean) extends Actor {
  import BinaryTreeNode._
  import BinaryTreeSet._

  var subtrees = Map[Position, ActorRef]()
  var removed = initiallyRemoved

  // optional
  def receive = normal

  // optional
  /** Handles `Operation` messages and `CopyTo` requests. */
  val normal: Receive = { 
    case BinaryTreeSet.Contains(requester, id, elem) => {
      if(this.elem == elem){
        requester ! BinaryTreeSet.ContainsResult(id, !removed)
      }
      else if(elem > this.elem){
        if(subtrees.contains(BinaryTreeNode.Right)){
           subtrees(BinaryTreeNode.Right) ! BinaryTreeSet.Contains(requester, id, elem)
        }
        else{
          requester ! BinaryTreeSet.ContainsResult(id, false)
        }
      }
      else if(elem < this.elem){
        if(subtrees.contains(BinaryTreeNode.Left)){
           subtrees(BinaryTreeNode.Left) ! BinaryTreeSet.Contains(requester, id, elem)
        }
        else{
          requester ! BinaryTreeSet.ContainsResult(id, false)
        }
      }
    }
    case BinaryTreeSet.Insert(requester, id, elem) => {
      if(this.elem == elem){
        removed = false
        requester ! BinaryTreeSet.OperationFinished(id)
      }
      else if(elem > this.elem){
        if(subtrees.contains(BinaryTreeNode.Right)){
           subtrees(BinaryTreeNode.Right) ! BinaryTreeSet.Insert(requester, id, elem)
        }
        else{
          val child = context.actorOf(BinaryTreeNode.props(elem, false))
          if(subtrees.contains(BinaryTreeNode.Left))
            subtrees = Map(BinaryTreeNode.Left -> subtrees(BinaryTreeNode.Left), BinaryTreeNode.Right -> child)  
          else
            subtrees = Map(BinaryTreeNode.Right -> child)
          requester ! BinaryTreeSet.OperationFinished(id)
        }
      }
      else if(elem < this.elem){
        if(subtrees.contains(BinaryTreeNode.Left)){
           subtrees(BinaryTreeNode.Left) ! BinaryTreeSet.Insert(requester, id, elem)
        }
        else{
          val child = context.actorOf(BinaryTreeNode.props(elem, false))
          if(subtrees.contains(BinaryTreeNode.Right))
            subtrees = Map(BinaryTreeNode.Left -> child, BinaryTreeNode.Right -> subtrees(BinaryTreeNode.Right))
          else
            subtrees = Map(BinaryTreeNode.Left -> child)
          requester ! BinaryTreeSet.OperationFinished(id)
        }
      }
    }
    case BinaryTreeSet.Remove(requester, id, elem) => {
      if(this.elem == elem){
        removed = true
        requester ! BinaryTreeSet.OperationFinished(id)
      }
      else if(elem > this.elem){
        if(subtrees.contains(BinaryTreeNode.Right)){
           subtrees(BinaryTreeNode.Right) ! BinaryTreeSet.Remove(requester, id, elem)
        }
        else{
          requester ! BinaryTreeSet.OperationFinished(id)
        }
      }
      else if(elem < this.elem){
        if(subtrees.contains(BinaryTreeNode.Left)){
           subtrees(BinaryTreeNode.Left) ! BinaryTreeSet.Remove(requester, id, elem)
        }
        else{
          requester ! BinaryTreeSet.OperationFinished(id)
        }
      }
    }
    case BinaryTreeNode.CopyTo(newRoot) => {
      var expectedRepliesCount = 0
      if(!removed){
        newRoot ! BinaryTreeSet.Insert(self, 0, elem)
        expectedRepliesCount += 1
      }
      if(subtrees.contains(BinaryTreeNode.Left)){
        subtrees(BinaryTreeNode.Left) ! BinaryTreeNode.CopyTo(newRoot)
        expectedRepliesCount += 1
      }
      if(subtrees.contains(BinaryTreeNode.Right)){
        subtrees(BinaryTreeNode.Right) ! BinaryTreeNode.CopyTo(newRoot)
        expectedRepliesCount += 1
      }
      if(expectedRepliesCount > 0)
        context.become(copying(expectedRepliesCount))
      else{
        val parent = context.parent
        parent ! BinaryTreeNode.CopyFinished
        //self ! PoisonPill
      }
    }
  }

  // optional
  /** `expected` is the set of ActorRefs whose replies we are waiting for,
    * `insertConfirmed` tracks whether the copy of this node to the new tree has been confirmed.
    */
  def copying(expectedRepliesCount: Int): Receive = {
    case BinaryTreeSet.OperationFinished(id) => {
      if(expectedRepliesCount > 1)
        context.become(copying(expectedRepliesCount - 1))
      else{
        val parent = context.parent
        parent ! BinaryTreeNode.CopyFinished
        //self ! PoisonPill 
      }
    }
    case BinaryTreeNode.CopyFinished => {
      if(expectedRepliesCount > 1)
        context.become(copying(expectedRepliesCount - 1))
      else{
        val parent = context.parent
        parent ! BinaryTreeNode.CopyFinished
        //self ! PoisonPill 
      }
    }
  }
}
