<?php

/**
 * @copyright Copyright (c) 2024 Sean Kau (kliensheng2020@gmail.com)
 * @license https://github.com/klsheng/myinvois-php-sdk/blob/main/LICENSE
 */

namespace Klsheng\Myinvois\Tests\Service\Document;

use PHPUnit\Framework\TestCase;
use Klsheng\Myinvois\MyInvoisClient;
use Klsheng\Myinvois\Service\Document\DocumentSubmissionService;

class DocumentSubmissionServiceTest extends TestCase
{
    /**
     * @covers \Klsheng\Myinvois\Service\AbstractService
     * @covers \Klsheng\Myinvois\Service\Document\DocumentSubmissionService
     */
    public function testGetSubmissionBuildsQuery()
    {
        $mockResponse = [
            'uuid' => 'submission-uuid',
            'documents' => [],
        ];

        $mockClient = $this->createMock(MyInvoisClient::class);
        $mockClient
            ->expects($this->once())
            ->method('request')
            ->with(
                'GET',
                'https://preprod-api.myinvois.hasil.gov.my/api/v1.0/documentsubmissions/sub-123?pageNo=2&pageSize=50'
            )
            ->willReturn($mockResponse);

        $service = new DocumentSubmissionService($mockClient);
        $response = $service->getSubmission('sub-123', 2, 50);

        $this->assertEquals($mockResponse, $response);
    }
}
