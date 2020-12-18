function CreateQueue(
    [string] $queueName,
    [string] $queueType = 'Private'
) {
    New-MsmqQueue -Name $queueName -Label $queueName -QueueType $queueType -Transactional | 
                Set-MsmqQueueAcl -UserName "Everyone" -Allow FullControl
}   

CreateQueue -queueName 'QUEUENAME'
CreateQueue -queueName 'QUEUENAME2'